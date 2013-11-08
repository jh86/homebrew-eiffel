require 'formula'

class Eiffelstudio < Formula
  homepage 'http://dev.eiffel.com/'

  stable do
    url 'http://downloads.sourceforge.net/project/eiffelstudio/EiffelStudio%207.2/Build_91284/PorterPackage_72_91284_gpl.tar'
    sha1 '6929a479980dc7a1d211bef93c8c5356fae7e9ef'
    version '7.2.91284'
  end

  devel do
    url 'http://downloads.sourceforge.net/project/eiffelstudio/EiffelStudio%207.3/Build_92766/PorterPackage_73_92766.tar'
    sha1 'b0c88590741c301a8de639859cc9f74549d337bf'
    version '7.3.92766'
  end

#  head 'https://svn.eiffel.com/eiffelstudio/trunk/Src', :revision => '93265'

# env :std

# can the depends be more specific?
  depends_on :x11
  depends_on 'gtk+'

  def shim_script arch
    <<-EOS.undent
      #!/bin/sh
      export ISE_EIFFEL=#{prefix}
      export ISE_PLATFORM=#{arch}
      export PKG_CONFIG_PATH=/opt/X11/lib/pkgconfig
      #{prefix}/studio/spec/#{arch}/bin/estudio "$@"
    EOS
  end

  def install
    arch = (MacOS.prefer_64_bit? ? "macosx-x86-64" : "macosx-x86")

    if build.head?
      cd "C" do
        ENV['ISE_PLATFORM'] = arch
        system "./quick_configure"
      end
      es_version = '73'
    else
      es_version = (version.to_s.split('.'))[0..1].join
    end

    # need pkg-config for X/GTK things
    ENV.append 'PATH', ":#{HOMEBREW_PREFIX}/opt/pkg-config/bin"

#     # ld bails with this option (in std env only?)
#     ENV['LDFLAGS'] = ENV['LDFLAGS'].sub ' -Wl,-headerpad_max_install_names', ''

    system "./compile_exes", arch

    eiffel_build_items = %w( C_library INSTALL.readme VERSION compatible contrib esbuilder eweasel examples library precomp studio tools unstable vision2_demo )
    eiffel_build_items.each {|i| prefix.install ("Eiffel#{es_version}/"+i)}
    [ 'ec', 'ecb' ].each {|b| chmod 0755, prefix/"studio/spec/#{arch}/bin/"+b}

    (bin+'estudio').write shim_script(arch)
  end

  test do
    system "false"
  end
end
