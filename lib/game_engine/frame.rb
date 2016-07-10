module GameEngine
  class Frame
    attr_reader :rows

    def initialize(width, height)
      @rows = height.times.map { ' ' * width }
    end

    def width
      @rows.first.size
    end

    def height
      @rows.size
    end

    def positions
      @rows.map.each_with_index do |row, y|
        row.chars.map.each_with_index do |char, x|
          [x, y] if char != ' '
        end.compact
      end.flatten(1)
    end

    def draw(x, y, sprite)
      lines = sprite.split("\n")

      lines.each_with_index do |line, i|
        if line.size > 0 && x+line.size <= self.width && y+lines.size <= self.height && y+i >= 0
          @rows[y+i][x..x+line.size-1] = line
        end
      end
    end

    def draw_center(y, sprite)
      sprite_width = sprite.split("\n").first.size
      x = self.width / 2 - sprite_width / 2
      draw x, y, sprite
    end

    def render
      @rows.each_with_index do |row, i|
        Frame.move_cursor 0, i
        print row
      end
    end

    def self.move_cursor(x, y)
      print "\033[#{y+1};#{x+1}H"
    end

    def self.clear_screen
      print "\033[2J"
    end

    def self.disable_cursor
      print "\x1B[?25l"
    end

    def self.enable_cursor
      print "\x1B[?25h"
    end

    def self.setup
      clear_screen
      disable_cursor

      $stdin.raw!
      at_exit do
        puts "\r"
        enable_cursor
        $stdin.cooked!
        system 'stty sane'
      end

      trap 'WINCH' do
        clear_screen
      end
    end
  end
end
