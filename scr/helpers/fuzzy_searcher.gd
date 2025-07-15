extends RefCounted
class_name FuzzySearcher

# Fuzzy search function that ranks potential matches based on input pattern
# Parameters:
# - input: String to search for
# - targets: Array of strings to search through
# Returns: Array of matching strings sorted by relevance (best match first)
static func mapped_search(input: String, targets: Array[Variant], getter: Callable, min_score: int = 0) -> Array:
	var mapped_targets: Array[Dictionary] = _mapper(targets, getter)
	
	# Normalize input to lowercase for case-insensitive matching
	var input_lower: String = input.to_lower()
	
	# Process each potential target string
	for target_dict: Dictionary in mapped_targets:
		# Normalize target and find matching character indices
		var target_lower: String = target_dict.get("string").to_lower()
		var indices := _get_matched_indices(input_lower, target_lower)
		
		if not indices.is_empty():
			# Calculate match quality score and store result
			var score: int = _calculate_score(target_lower.length(), indices)
			target_dict["score"] = score
	
	# Filter targets below min_score before sorting
	var filtered_targets = mapped_targets.filter(func(mapped_target: Dictionary): return mapped_target["score"] >= min_score)
	
	if filtered_targets.is_empty():
		filtered_targets = mapped_targets
	
	# Custom sort function for ranking results
	# Primary sort: descending score (best matches first)
	# Secondary sort: ascending length (prefer shorter matches when scores tie)
	filtered_targets.sort_custom(func(a: Dictionary, b: Dictionary): 
		if a["score"] == b["score"]:
			return a["string"].length() < b["string"].length()
		return a["score"] > b["score"]
	)
	
	# Extract just the strings from the sorted results
	return filtered_targets.map(func(mapped_target: Dictionary): return mapped_target["object"])


static func _mapper(targets: Array[Variant], getter: Callable) -> Array[Dictionary]:
	var mapped_values: Array[Dictionary] = []
	for target: Variant in targets:
		mapped_values.append({"object": target, "string": getter.call(target), "score": -1})
	return mapped_values


# Finds positions of input characters in target string (in order)
# Returns empty array if no match, or array of indices if match found
static func _get_matched_indices(input: String, target: String) -> Array:
	var indices: Array[int] = []
	var input_len: int = input.length()
	var target_len: int = target.length()
	var i: int = 0  # Input position tracker
	var j: int = 0  # Target position tracker
	
	# Find sequential matches while both strings have characters
	while i < input_len and j < target_len:
		if input[i] == target[j]:
			indices.append(j)
			i += 1  # Move to next input character
		j += 1  # Always move target character
	
	# Only return indices if we matched all input characters
	return indices if i == input_len else []


# Calculates match quality score based on match characteristics
# Scoring priorities:
# - Consecutive matches (most important)
# - Early matches in target string
# - Minimal gaps between matched characters
# - Shorter target strings
static func _calculate_score(target_length: int, indices: Array) -> int:
	if indices.is_empty():
		return 0  # No match
	
	var consecutive_pairs: int = 0  # Count of adjacent matches
	var total_gaps: int = 0  # Total spaces between matches
	var start_index: int = indices[0]  # Position of first match
	
	# Analyze gaps between matches and count consecutive pairs
	for i in range(1, indices.size()):
		var gap: int = indices[i] - indices[i-1] - 1
		total_gaps += gap
		if gap == 0:
			consecutive_pairs += 1  # Found consecutive characters
	
	# Score formula breakdown:
	# - +100 per consecutive pair (emphasize sequential matches)
	# - -1 per gap character between matches
	# - -1 per position away from start
	# - -1 per character in target length (prefer shorter matches)
	return 100 * consecutive_pairs - start_index - total_gaps - target_length
