require 'ohm'
class QuestionStore < Ohm::Model
  attribute :description
  collection :answers, :AnswerStore

  index :description
  def ui_json
    self.attributes.merge(self.to_hash)
  end
end


class AnswerStore < Ohm::Model
  attribute :description
  reference :question, :QuestionStore

  index :description
  def ui_json
    self.attributes.merge(self.to_hash)
  end
end
