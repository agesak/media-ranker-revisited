require "test_helper"

describe WorksController do
  let(:existing_work) { works(:album) }
  let(:dans_work) { works(:danswork) }

  describe "root" do
    it "succeeds with all media types" do
      get root_path

      must_respond_with :success
    end

    it "succeeds with one media type absent" do
      only_book = works(:poodr)
      only_book.destroy

      get root_path

      must_respond_with :success
    end

    it "succeeds with no media" do
      Work.all do |work|
        work.destroy
      end

      get root_path

      must_respond_with :success
    end
  end

  CATEGORIES = %w(albums books movies)
  INVALID_CATEGORIES = ["nope", "42", "", "  ", "albumstrailingtext"]

  describe "index" do

    describe "site member" do
      it "succeeds when there are works" do
        user = users(:dan)
        perform_login(user)
        get works_path

        must_respond_with :success
      end

      it "succeeds when there are no works" do
        user = users(:dan)
        perform_login(user)
        Work.all do |work|
          work.destroy
        end

        get works_path

        must_respond_with :success
      end
    end

    describe "guest" do

      it "redirects for a guest user" do
        get works_path

        expect(flash[:status]).must_equal :failure
        expect(flash[:result_text]).must_equal  "You must be logged in to view this"
        must_redirect_to root_path
      end
    end
  end

  describe "new" do

    describe "site member" do
      it "succeeds" do
        perform_login(users(:dan))
        get new_work_path
  
        must_respond_with :success
      end
    end

    describe "guest" do
      it "redirects for a guest user" do
        get new_work_path
        expect(flash[:status]).must_equal :failure
        expect(flash[:result_text]).must_equal  "You must be logged in to view this"
        must_redirect_to root_path
      end
    end

  end

  describe "create" do

    describe "site member" do
      it "creates a work with valid data for a real category" do
        perform_login(users(:dan))
        new_work = { work: { title: "Dirty Computer", category: "album" } }

        expect {
          post works_path, params: new_work
        }.must_change "Work.count", 1
  
        new_work_id = Work.find_by(title: "Dirty Computer").id
  
        must_respond_with :redirect
        must_redirect_to work_path(new_work_id)
      end

    it "renders bad_request and does not update the DB for bogus data" do
      perform_login(users(:dan))
      bad_work = { work: { title: nil, category: "book" } }

      expect {
        post works_path, params: bad_work
      }.wont_change "Work.count"

      must_respond_with :bad_request
    end

    it "renders 400 bad_request for bogus categories" do
      perform_login(users(:dan))
      INVALID_CATEGORIES.each do |category|
        invalid_work = { work: { title: "Invalid Work", category: category } }

        expect { post works_path, params: invalid_work }.wont_change "Work.count"

        expect(Work.find_by(title: "Invalid Work", category: category)).must_be_nil
        must_respond_with :bad_request
      end
    end

    describe "guest" do
      it "redirects for a guest user" do
        new_work = { work: { title: "Dirty Computer", category: "album" } }

        expect {
          post works_path, params: new_work
        }.wont_change "Work.count"

        expect(flash[:status]).must_equal :failure
        expect(flash[:result_text]).must_equal  "You must be logged in to view this"
        must_redirect_to root_path
      end
    end
  end
end

  describe "show" do
    describe "site member" do
      it "succeeds for an extant work ID" do
        user = users(:dan)
        perform_login(user)
        get work_path(existing_work.id)
  
        must_respond_with :success
      end

      it "renders 404 not_found for a bogus work ID" do
        user = users(:dan)
        perform_login(user)
        destroyed_id = existing_work.id
        existing_work.destroy
  
        get work_path(destroyed_id)
  
        must_respond_with :not_found
      end
    end

    describe "guest" do
      it "redirects for a guest user" do
        get work_path(existing_work.id)
        expect(flash[:status]).must_equal :failure
        expect(flash[:result_text]).must_equal  "You must be logged in to view this"
        must_redirect_to root_path
      end
    end
  end

  describe "edit" do
    it "succeeds for an extant work ID" do
      perform_login(users(:dan))
      get edit_work_path(dans_work.id)

      must_respond_with :success
    end

    it "redirects for an unauthorized user" do
      perform_login(users(:kari))
      get edit_work_path(dans_work.id)

      expect(flash[:status]).must_equal :failure
      expect(flash[:result_text]).must_equal  "You are not authorized to do that"
      must_redirect_to root_path
    end

    it "renders 404 not_found for a bogus work ID" do
      bogus_id = existing_work.id
      existing_work.destroy

      get edit_work_path(bogus_id)

      must_respond_with :not_found
    end
  end

  describe "update" do
    describe "site member" do
      it "succeeds for valid data and an extant work ID" do
        user = perform_login(users(:dan))
        updates = { work: { title: "Dirty Computer" } }
  
        expect {
          put work_path(dans_work.id), params: updates
        }.wont_change "Work.count"
  
        updated_work = Work.find_by(id: dans_work.id)
  
        expect(updated_work.title).must_equal "Dirty Computer"
        must_respond_with :redirect
        must_redirect_to work_path(dans_work.id)
      end

      it "renders bad_request for bogus data" do
        perform_login(users(:dan))
        updates = { work: { title: nil } }
  
        expect {
          put work_path(dans_work.id), params: updates
        }.wont_change "Work.count"
  
        work = Work.find_by(id: dans_work.id)
  
        must_respond_with :not_found
      end

      it "redirects for an unauthorized user" do
        perform_login(users(:kari))
        updates = { work: { title: "Dirty Computer" } }
  
        expect {
          put work_path(dans_work.id), params: updates
        }.wont_change "Work.count"

        expect(flash[:status]).must_equal :failure
        expect(flash[:result_text]).must_equal  "You are not authorized to do that"
        must_redirect_to root_path
      end
    end

    describe "guest" do
      it "redirects for a guest user" do
        updates = { work: { title: "Dirty Computer" } }
  
        expect {
          put work_path(dans_work.id), params: updates
        }.wont_change "Work.count"

        expect(flash[:status]).must_equal :failure
        expect(flash[:result_text]).must_equal  "You must be logged in to view this"
        must_redirect_to root_path
      end
    end
  end

  describe "destroy" do
    it "succeeds for an extant work ID" do
      user = perform_login(users(:dan))
      expect {
        delete work_path(dans_work.id)
      }.must_change "Work.count", -1

      must_respond_with :redirect
      must_redirect_to root_path
    end

    it "redirects for an unauthorized user" do
      perform_login(users(:kari))
      expect {
        delete work_path(dans_work.id)
      }.wont_change "Work.count"

      expect(flash[:status]).must_equal :failure
      expect(flash[:result_text]).must_equal  "You are not authorized to do that"
      must_redirect_to root_path
    end

    it "renders 404 not_found and does not update the DB for a bogus work ID" do
      bogus_id = existing_work.id
      existing_work.destroy

      expect {
        delete work_path(bogus_id)
      }.wont_change "Work.count"

      must_respond_with :not_found
    end
  end

  describe "upvote" do
    it "redirects to the work page if no user is logged in" do
      expect{post upvote_path(existing_work.id)}.wont_change "Vote.count"
      expect(flash[:result_text]).must_equal "You must be logged in to view this"
      expect(flash[:status]).must_equal :failure
    end

    # it "redirects to the work page after the user has logged out" do
    #   skip
    # end

    it "succeeds for a logged-in user and a fresh user-vote pair" do
      user = users(:dan)
      poodr = works(:poodr)
      perform_login(user)

      expect{post upvote_path(poodr.id)}.must_differ "Vote.count", 1
      expect(user.votes.length).must_equal 3
      expect(flash[:result_text]).must_equal "Successfully upvoted!"
    end

    it "redirects to the work page if the user has already voted for that work" do
      user = users(:dan)
      perform_login(user)
      expect{post upvote_path(existing_work.id)}.wont_change "Vote.count"
      must_redirect_to work_path(existing_work.id)
    end
  end
end