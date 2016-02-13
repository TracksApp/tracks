require 'rails_helper'

RSpec.describe Todo do
  fixtures :todos, :users, :contexts, :projects

  let(:not_completed1) { Todo.find(1).reload }
  let(:not_completed2) { Todo.find(2).reload }
  let(:completed) { Todo.find(8).reload }

  # Test loading a todo item
  it 'loads a todo' do
    expect(not_completed1).to be_a(Todo)
    expect(not_completed1.id).to eq(1)
    expect(not_completed1.context_id).to eq(1)
    expect(not_completed1.project_id).to eq(2)
    expect(not_completed1.description).to eq('Call Bill Gates to find out how much he makes per day')
    expect(not_completed1.notes).to be_nil
    expect(not_completed1.completed?).to be(false)
    expect(not_completed1.created_at.utc).to eq(1.week.ago.utc.beginning_of_day)
    expect(not_completed1.due.utc).to eq(2.week.from_now.utc.beginning_of_day)
    expect(not_completed1.completed_at).to be_nil
    expect(not_completed1.user_id).to eq(1)
  end

  describe '#completed?' do
    it 'is true for a completed todo' do
      expect(completed.completed?).to be(true)
    end

    it 'is false for an incomplete todo' do
      expect(not_completed1.completed?).to be(false)
    end
  end

  describe '#completed_at' do
    it 'returns a Time object for a completed todo' do
      # TODO: test for something more specific
      expect(completed.completed_at).to be_a(Time)
    end

    it 'is nil for an icomplete todo' do
      expect(not_completed1.completed_at).to be_nil
    end
  end

  describe 'Validations' do
    # TODO: use shoulda-matchers

    it 'validates presence of description' do
      expect(not_completed2.description).to eq('Call dinosaur exterminator')
      not_completed2.description = ''
      expect(not_completed2.save).to be(false)
      expect(not_completed2.errors.count).to eq(1)
      expect(not_completed2.errors[:description][0]).to eq("can't be blank")
    end

    it 'validates length of description' do
      expect(not_completed2.description).to eq('Call dinosaur exterminator')
      not_completed2.description = 'X' * (Todo::MAX_DESCRIPTION_LENGTH + 1)
      expect(not_completed2.save).to be(false)
      expect(not_completed2.errors.count).to eq(1)
      expect(not_completed2.errors[:description][0]).to eq(
        "is too long (maximum is #{Todo::MAX_DESCRIPTION_LENGTH} characters)"
      )
    end

    it 'validates length of notes' do
      expect(not_completed2.notes).to eq('Ask him if I need to hire a skip for the corpses.')
      not_completed2.notes = 'X' * (Todo::MAX_NOTES_LENGTH + 1)
      expect(not_completed2.save).to be(false)
      expect(not_completed2.errors.count).to eq(1)
      expect(not_completed2.errors[:notes][0]).to eq(
        "is too long (maximum is #{Todo::MAX_NOTES_LENGTH} characters)"
      )
    end

    it 'validates show_from is a date in the future' do
      not_completed2.show_from = 1.week.ago
      expect(not_completed2.save).to be(false)
      expect(not_completed2.errors.count).to eq(1)
      expect(not_completed2.errors[:show_from][0]).to eq('must be a date in the future')
    end

    it 'validates circular dependencies' do
      completed.activate!
      not_completed3 = completed

      # 2 -> 1
      not_completed1.add_predecessor(not_completed2)
      expect(not_completed1.save!).to be(true)
      expect(not_completed2.successors.count).to eq(1)

      # 3 -> 2 -> 1
      not_completed2.add_predecessor(not_completed3)
      expect(not_completed2.save!).to be(true)
      expect(not_completed3.successors.count).to eq(1)

      # 1 -> 3 -> 2 -> 1 == circle
      expect { not_completed3.add_predecessor(not_completed1) }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end
