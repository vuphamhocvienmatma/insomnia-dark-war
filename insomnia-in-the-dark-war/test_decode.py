import sys

bad_string = "Ã°Å¸â€œâ€¹ NhiÃ¡Â»â€¡m VÃ¡Â»Â¥"

try:
    # It might be doubly or triply encoded...
    # First, let's try to encode back to cp1252, then decode as utf-8
    b1 = bad_string.encode('cp1252')
    s1 = b1.decode('utf-8')
    print("Attempt 1:", s1)
    
    b2 = s1.encode('cp1252')
    s2 = b2.decode('utf-8')
    print("Attempt 2:", s2)
except Exception as e:
    print("Error:", e)
