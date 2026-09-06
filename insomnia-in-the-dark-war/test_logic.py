def test(line):
    try:
        b = line.encode('cp1252')
        new_line = b.decode('utf-8')
        return new_line
    except (UnicodeEncodeError, UnicodeDecodeError):
        return line

print("Test 1 (ASCII):", test("var x = 10"))
print("Test 2 (Mojibake):", test("Ã°Å¸â€œâ€¹ NhiÃ¡Â»â€¡m VÃ¡Â»Â¥"))
print("Test 3 (Correct VN):", test("Chào chú mày, vứt phế liệu đi!"))
