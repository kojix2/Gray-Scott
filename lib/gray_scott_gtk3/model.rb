module GrayScottGtk3
  class Model
    # 短縮
    class Numo::SFloat
      alias _ inplace
    end
    SFloat = Numo::SFloat
    UInt8  = Numo::UInt8

    # パラメータ
    Dx = 0.01
    Dt = 1

    # Diffusion rates
    Du = 2e-5
    Dv = 1e-5

    def initialize(width: 256, height: 256)
      # Feed rate
      @f = 0.04
      # Kill rate
      @k = 0.06

      # 初期化
      @u = SFloat.ones height, width
      @v = SFloat.zeros height, width
      @show_u = true
      @color = 'colorful'
    end

    def clear
      @u.fill 1.0
      @v.fill 0.0
    end

    def update_u_v(u = @u, v = @v)
      l_u = SFloat.laplacian2d u
      l_v = SFloat.laplacian2d v

      uvv = u * v * v
      dudt = Du * l_u - uvv + @f * (1.0 - u)
      dvdt = Dv * l_v + uvv - (@f + @k) * v
      u._ + (Dt * dudt)
      v._ + (Dt * dvdt)
      @u = u
      @v = v
    end

    def uint8_zeros_256(ch, ar)
      d = UInt8.zeros(*ar.shape, 3)
      d[true, true, ch] = UInt8.cast(ar * 256)
      d
    end

    def to_pixbuf(ar, color_type = @color)
      data = colorize(ar, color_type).to_string
      height, width = ar.shape
      pixbuf = GdkPixbuf::Pixbuf.new data: data, width: width, height: height
      pixbuf.scale_simple 512, 512, :bilinear
    end

    def hsv2rgb(h)
      height, width = h.shape
      i = UInt8.cast(h * 6)
      f = (h * 6.0) - i
      p = UInt8.zeros height, width, 1
      v = UInt8.new(height, width, 1).fill 255
      q = (1.0 - f) * 256
      t = f * 256
      rgb = UInt8.zeros height, width, 3
      t = UInt8.cast(t).expand_dims(2)
      i = UInt8.dstack([i, i, i])
      rgb[i.eq 0] = UInt8.dstack([v, t, p])[i.eq 0]
      rgb[i.eq 1] = UInt8.dstack([q, v, p])[i.eq 1]
      rgb[i.eq 2] = UInt8.dstack([p, v, t])[i.eq 2]
      rgb[i.eq 3] = UInt8.dstack([p, q, v])[i.eq 3]
      rgb[i.eq 4] = UInt8.dstack([t, p, v])[i.eq 4]
      rgb[i.eq 5] = UInt8.dstack([v, p, q])[i.eq 5]
      rgb
    end
  end
end
