class Parseachangelog < Formula
  desc "A Go library and CLI tool for parsing Keep a Changelog markdown files into structured JSON format"
  homepage "https://github.com/ridakk/parseachangelog"
  version "0.1.1"  # Update this with your first release version

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/ridakk/parseachangelog/releases/download/v#{version}/parseachangelog-darwin-amd64.tar.gz"
      sha256 "" # darwin-amd64
    end
    if Hardware::CPU.arm?
      url "https://github.com/ridakk/parseachangelog/releases/download/v#{version}/parseachangelog-darwin-arm64.tar.gz"
      sha256 "" # darwin-arm64
    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/ridakk/parseachangelog/releases/download/v#{version}/parseachangelog-linux-amd64.tar.gz"
      sha256 "" # linux-amd64
    end
    if Hardware::CPU.arm?
      url "https://github.com/ridakk/parseachangelog/releases/download/v#{version}/parseachangelog-linux-arm64.tar.gz"
      sha256 "" # linux-arm64
    end
  end

  def install
    bin.install "parseachangelog"
  end

  test do
    system "#{bin}/parseachangelog", "--version"
  end
end 