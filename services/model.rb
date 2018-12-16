require 'ohm'
Ohm.redis = Redic.new('redis://127.0.0.1:6379')

class QuestionStore < Ohm::Model
  attribute :description
  collection :answers, :AnswerStore

  index :description
  def ui_json
    attributes.merge(to_hash)
  end
end

class AnswerStore < Ohm::Model
  attribute :description
  reference :question, :QuestionStore

  index :description
  def ui_json
    attributes.merge(to_hash)
  end
end
