Shoes.app do
  stack do
    @p = para "Button info..."
    @push = button "Play with me!"
    @push.click {
      @p.replace(strong("Button Clicked!"))
    }
    @push.hover {
      @p.replace(em("Hovered over the button..."))
    }
    @push.leave {
      @p.replace(em("Left the button..."))
    }
    @lp = para "..."
    @push.motion { |x, y|
      @lp.replace("x: %.2f y: %.2f" % [x, y])
    }
  end
end
