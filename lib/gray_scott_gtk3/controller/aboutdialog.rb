module GrayScottGtk3
  class Controller
    class AboutDialog 
      def initialize(resource_dir)
        @a = Gtk::AboutDialog.new
        @a.program_name = 'Gray-Scott'
        @a.logo = GdkPixbuf::Pixbuf.new(file: File.join(resource_dir, 'about_icon.png'))
        @a.authors = ['kojix2']
        @a.version = GrayScottGtk3::VERSION
        @a.run
        @a.destroy
      end
    end
  end
end