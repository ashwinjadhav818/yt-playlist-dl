param(
    [Parameter(Mandatory = $true)]
    [string]$PlaylistUrl,

    [string]$OutputDir = "$PWD\yt_playlist"
)

# Ensure yt-dlp is installed and accessible
if (-not (Get-Command yt-dlp -ErrorAction SilentlyContinue)) {
    Write-Error "yt-dlp is not installed or not in PATH. Please install it first."
    exit 1
}

# Create output directory if it doesn't exist
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir | Out-Null
}

Write-Host "Fetching playlist: $PlaylistUrl`n"

# List all videos in the playlist
$videoList = yt-dlp --flat-playlist --print "%(title)s - %(uploader)s - %(id)s" $PlaylistUrl
Write-Host "Playlist videos:`n"
$videoList | ForEach-Object { Write-Host $_ }

# Save list to file
$videoList | Out-File -FilePath "$OutputDir\playlist.txt" -Encoding UTF8

Write-Host "`nDownloading audio in M4A (AAC)...`n"

# Download in best available audio format, prefer m4a (AAC) directly
yt-dlp `
    -o "$OutputDir\%(title)s - %(artist)s.%(ext)s" `
    -f "bestaudio[ext=m4a]/bestaudio" `
    --extract-audio `
    --audio-format m4a `
    --audio-quality 0 `
    $PlaylistUrl

Write-Host "`nDone! Files saved in $OutputDir"
