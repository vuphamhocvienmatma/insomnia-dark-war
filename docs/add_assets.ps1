mkdir C:\Users\ezral\Downloads\insomnia-dark-war\assets_raw
cd C:\Users\ezral\Downloads\insomnia-dark-war\assets_raw

Invoke-WebRequest -Uri "https://kenney.nl/media/pages/assets/tiny-dungeon/0b49e8bc3e-1709885966/kenney_tiny-dungeon.zip" -OutFile "tiny-dungeon.zip"
Invoke-WebRequest -Uri "https://kenney.nl/media/pages/assets/1-bit-pack/2c8b8c3d-1709885831/kenney_1-bit-pack.zip" -OutFile "1-bit-pack.zip"
Invoke-WebRequest -Uri "https://kenney.nl/media/pages/assets/game-icons/72e39c7d5e-1709885943/kenney_game-icons.zip" -OutFile "game-icons.zip"

# Giải nén tất cả
Expand-Archive -Path "*.zip" -DestinationPath "."