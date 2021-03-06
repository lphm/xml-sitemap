require 'spec_helper'

describe XmlSitemap::Index do
  let(:base_time) { Time.gm(2011, 6, 1, 0, 0, 1) }

  describe '#new' do
    it 'should be valid if no sitemaps were supplied' do
      index = XmlSitemap::Index.new
      index.render.should == fixture('empty_index.xml')
    end
  
    it 'should raise error if passing a wrong object' do
      index = XmlSitemap::Index.new
      expect { index.add(nil) }.to raise_error ArgumentError, 'XmlSitemap::Map object requred!'
    end
  
    it 'should raise error if passing an empty sitemap' do
      map = XmlSitemap::Map.new('foobar.com', :home => false)
      index = XmlSitemap::Index.new
      expect { index.add(map) }.to raise_error ArgumentError, 'Map is empty!'
    end
  end

  describe '#render' do
    it 'renders a proper index' do
      m1 = XmlSitemap::Map.new('foobar.com', :time => base_time) { |m| m.add('about') }
      m2 = XmlSitemap::Map.new('foobar.com', :time => base_time) { |m| m.add('about') }
    
      index = XmlSitemap::Index.new do |i|
        i.add(m1)
        i.add(m2)
      end
    
      index.render.should == fixture('sample_index.xml')
    end
  end

  describe '#render_to' do
    let(:index_path) { "/tmp/xml_index.xml" }

    after :all do
      File.delete_if_exists(index_path)
    end

    it 'saves index contents to the filesystem' do
      m1 = XmlSitemap::Map.new('foobar.com', :time => base_time) { |m| m.add('about') }
      m2 = XmlSitemap::Map.new('foobar.com', :time => base_time) { |m| m.add('about') }
      
      index = XmlSitemap::Index.new do |i|
        i.add(m1)
        i.add(m2)
      end
      
      index.render_to(index_path)
      File.read(index_path).should eq(fixture('sample_index.xml'))
    end
    
    it 'should have separate running offsets for different map groups' do
      maps = %w(first second second third).map do |name|
        XmlSitemap::Map.new('foobar.com', :time => base_time, :group => name)  { |m| m.add('about') }
      end
      
      index = XmlSitemap::Index.new do |i|
        maps.each { |m| i.add(m) }
      end
      
      index.render_to(index_path)
      File.read(index_path).should eq(fixture('group_index.xml'))
    end
  end
end
