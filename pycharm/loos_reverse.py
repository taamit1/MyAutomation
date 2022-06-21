def reverse(text):
    rev_text = ""
    for char in text:
        rev_text = char + rev_text
    return rev_text

reverse("hello")