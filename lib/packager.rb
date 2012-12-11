class Packager
  PACKAGES    = ["zshrc","oh-my-zsh","vim","vimrc","bashrc","screenrc"]
  BASE_DIR    = "#{Dir.pwd}/files"
  INSTALL_DIR = File.expand_path("~")

  def self.available_setups
    available = Array.new

    PACKAGES.each do |package|
      exists_call   = clean_name("#{package}_available")
      install_call  = clean_name("#{package}_install")
      available << package if self.respond_to?(exists_call) and self.respond_to?(install_call) and self.send(exists_call)
    end

    return available
  end

  def self.install_packages(packages)
    packages.each do |package|
      exists_call   = clean_name("#{package}_available")
      install_call  = clean_name("#{package}_install")
      if self.respond_to?(exists_call) and self.respond_to?(install_call) and self.send(exists_call)
        self.send(install_call)
      end
    end
  end

  def self.remove_packages(packages)
    packages.each do |package|
      exists_call = clean_name("#{package}_available")
      remove_call = clean_name("#{package}_remove")
      if self.respond_to?(exists_call) and self.respond_to?(remove_call) and self.send(exists_call)
        self.send(remove_call)
      end
    end
  end

private

  def self.clean_name(name)
    return name.gsub("-","_")
  end


#-----EXISTS CALLS
  PACKAGES.each do |package|
    class_eval %Q{
      def self.#{clean_name(package)}_available
        return true if File.exists?("#{BASE_DIR}/#{package}")
        return false
      end
    }
  end

#-----INSTALL CALLS
  PACKAGES.each do |package|
    class_eval %Q{
      def self.#{clean_name(package)}_install
        print_message "installing #{package}"
        print_done_message link("#{BASE_DIR}/#{package}", "#{INSTALL_DIR}/.#{package}")
      end
    }
  end

#-----REMOVE CALLS
  PACKAGES.each do |package|
    class_eval %Q{
      def self.#{clean_name(package)}_remove
        print_message "removing #{package}"
        print_done_message unlink("#{BASE_DIR}/#{package}", "#{INSTALL_DIR}/.#{package}")
      end
    }
  end

  def self.zshrc_remove
    print_message "removing zshrc"
    print_done_message unlink("#{BASE_DIR}/zshrc", "#{INSTALL_DIR}/.zshrc")
  end

#------Helpful Functions
  def self.link(src, dst)
    begin
      File.symlink(src, dst)
    rescue Errno::EEXIST => e
      return "File #{dst} already exists"
    end
    return true
  end

  def self.unlink(src, dst)
    if File.symlink?(dst) and File.readlink(dst) == src
      File.unlink(dst)
    else
      return "#{dst} is not a symlink" unless File.symlink?(dst)
      return "#{dst} is not linked to #{src}" unless File.readlink(dst) == src
      return "UNKNOWN"
    end
    return true
  end

  def self.print_message(message, size=30, default=".")
    str = message.clone
    str = str+("."*(30-str.length)) if str.length < 30
    print str
  end

  def self.print_done_message(message)
    if message == true
      puts "done"
    else
      puts "failed"
      puts "   |--: #{message}"
    end
  end

end


