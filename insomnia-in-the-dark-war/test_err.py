bad = "ÃƒÂ°Ã…Â¸Ã¢â‚¬Å“Ã¢â‚¬Â¹ Ãƒâ€žÃ‚Â ÃƒÆ’Ã‚Â³ng"
try:
    b = bad.encode('cp1252')
    s = b.decode('utf-8')
    print("Success 1:", len(s))
    b2 = s.encode('cp1252')
    s2 = b2.decode('utf-8')
    print("Success 2:", len(s2))
except Exception as e:
    print(e)
