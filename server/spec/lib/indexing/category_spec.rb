require 'spec_helper'
describe Indexing::Category do
  
  context "unit specs" do
    before(:each) do
      @type = stub :some_type, :name => :some_type
    end
    describe "virtual?" do
      context "with virtual true" do
        before(:each) do
          @category = Indexing::Category.new :some_name, @type, virtual: true
        end
        it "returns the right value" do
          @category.virtual?.should == true
        end
      end
      context "with virtual object" do
        before(:each) do
          @category = Indexing::Category.new :some_name, @type, :virtual => 123.6
        end
        it "returns the right value" do
          @category.virtual?.should == true
        end
      end
      context "with virtual nil" do
        before(:each) do
          @category = Indexing::Category.new :some_name, @type, :virtual => nil
        end
        it "returns the right value" do
          @category.virtual?.should == false
        end
      end
      context "with virtual false" do
        before(:each) do
          @category = Indexing::Category.new :some_name, @type, :virtual => false
        end
        it "returns the right value" do
          @category.virtual?.should == false
        end
      end
    end
    describe "tokenizer" do
      context "with specific tokenizer" do
        before(:each) do
          @category = Indexing::Category.new :some_name, @type, tokenizer: Tokenizers::Index.new
        end
        it "caches" do
          @category.tokenizer.should == @category.tokenizer
        end
        it "returns an instance" do
          @category.tokenizer.should be_kind_of(Tokenizers::Index)
        end
      end
    end
    describe "indexer" do
      context "with default indexer" do
        before(:each) do
          @category = Indexing::Category.new :some_name, @type
        end
        it "caches" do
          @category.indexer.should == @category.indexer
        end
      end
      context "with specific indexer" do
        before(:each) do
          @category = Indexing::Category.new :some_name, @type, tokenizer: Indexers::Default
        end
        it "caches" do
          @category.indexer.should == @category.indexer
        end
        it "returns an instance" do
          @category.indexer.should be_kind_of(Indexers::Default)
        end
        it "creates a new instance of the right class" do
          Indexers::Default.should_receive(:new).once.with @type, @category
          
          @category.indexer
        end
      end
    end
    describe "cache" do
      before(:each) do
        @category = Indexing::Category.new :some_name, @type
        @category.stub! :prepare_cache_directory
        
        @category.stub! :generate_caches
      end
      it "prepares the cache directory" do
        @category.should_receive(:prepare_cache_directory).once.with
        
        @category.cache
      end
      it "tells the indexer to index" do
        @category.should_receive(:generate_caches).once.with
        
        @category.cache
      end
    end
    describe "prepare_cache_directory" do
      before(:each) do
        @category = Indexing::Category.new :some_name, @type
        
        @category.stub! :cache_directory => :some_cache_directory
      end
      it "tells the FileUtils to mkdir_p" do
        FileUtils.should_receive(:mkdir_p).once.with :some_cache_directory
        
        @category.prepare_cache_directory
      end
    end
    describe "index" do
      before(:each) do
        @category = Indexing::Category.new :some_name, @type
        @category.stub! :prepare_cache_directory
        
        @indexer = stub :indexer, :index => nil
        @category.stub! :indexer => @indexer
      end
      it "prepares the cache directory" do
        @category.should_receive(:prepare_cache_directory).once.with
        
        @category.index
      end
      it "tells the indexer to index" do
        @indexer.should_receive(:index).once.with
        
        @category.index
      end
    end
    describe "source" do
      context "with source" do
        before(:each) do
          @category = Indexing::Category.new :some_name, @type, :source => :some_given_source
        end
        it "returns the given source" do
          @category.source.should == :some_given_source
        end
      end
      context "without source" do
        before(:each) do
          @type = stub :type, :name => :some_type, :source => :some_type_source
          
          @category = Indexing::Category.new :some_name, @type
        end
        it "returns the type's source" do
          @category.source.should == :some_type_source
        end
      end
    end
    context "name symbol" do
      before(:each) do
        @category = Indexing::Category.new :some_name, @type
      end
      describe "search_index_file_name" do
        it "returns the right file name" do
          @category.search_index_file_name.should == 'some/search/root/index/test/some_type/prepared_some_name_index.txt'
        end
      end
    end
    context "name string" do
      it "works" do
        @category = Indexing::Category.new 'some_name', @type
      end
    end
  end
  
end