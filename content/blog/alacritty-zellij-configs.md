---
title: "Alacritty - Zellij - мои конфигурационные файлы."
date: 2025-08-16T00:00:00+05:00
summary: ""
categories:
- rust
- macos
- alacritty
- zellij
- terminal
- JetBrains
- Mono Fonts
---
Выкладываю свои конфигурационные файлы.
<!--more-->


# Intro

Сейчас в основном работаю за MacBook. Нашел для себя рабочий набор программного обеспечения - Alacritty, Zellij, NeoVim. Фонт выбрал JetBrains Mono NL.
 

# Alacritty

[Alacritty](https://alacritty.org/) - это терминал с поддержкой рендеринга, написан на rust. О существование данной программы узнал из [этого поста на Linux.Org.RU](https://www.linux.org.ru/forum/talks/15282317).

~~~yaml
# Configuration for Alacritty, the GPU enhanced terminal emulator
env:
  TERM: "xterm-256color"

window:
  opacity: 0.9
  padding:
    x: 10
    y: 10
  decorations: "Full"
  decorations_theme_variant: "Light"

scrolling:
  # Maximum number of lines in the scrollback buffer.
  # Specifying '0' will disable scrolling.
  history: 0

# When true, bold text is drawn using the bright variant of colors.
draw_bold_text_with_bright_colors: true

# Font configuration (changes require restart)
font:
  # Normal (roman) font face
  normal:
    family: "JetBrains Mono NL"
    # The `style` can be specified to pick a specific face.
    style: Regular

  # Bold font face
  bold:
    family: "JetBrains Mono NL"
    # The `style` can be specified to pick a specific face.
    style: Bold

  # Italic font face
  italic:
    family: "JetBrains Mono NL"
    # The `style` can be specified to pick a specific face.
    style: Italic

  # Italic Bold font face
  italic:
    family: "JetBrains Mono NL"
    # The `style` can be specified to pick a specific face.
    style: Bold Italic

  # Point size of the font
  size: 15.0

 # Live config reload (changes require restart)
live_config_reload: true

colors:
  # Default colors
  primary:
    background: '0x0A0E14'
    foreground: '0xB3B1AD'

  # Normal colors
  normal:
    black: '0x01060E'
    red: '0xEA6C73'
    green: '0x91B362'
    yellow: '0xF9AF4F'
    blue: '0x53BDFA'
    magenta: '0xFAE994'
    cyan: '0x90E1C6'
    white: '0xC7C7C7'

  # Bright colors
  bright:
    black: '0x686868'
    red: '0xF07178'
    green: '0xC2D94C'
    yellow: '0xFFB454'
    blue: '0x59C2FF'
    magenta: '0xFFEE99'
    cyan: '0x95E6CB'
    white: '0xFFFFFF'

#import:
#  # - "~/.config/alacritty/themes/catppuccin-mocha.yml"
#  # - "~/.config/alacritty/themes/catppuccin-latte.yml"
#  #- "~/.config/alacritty/themes/catppuccin-fratte.yml"
#  - "~/.config/alacritty/themes/solarized-light.yml"
~~~

# Zellij
[Zellij](https://zellij.dev/) - альтернатива screen, tmux. Написан на Rust. 

Пока конфигурации нет, так как они поменяли формат, я еще не определился какой лучше.

