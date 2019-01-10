class Task < ApplicationRecord
    validates :name, presence: true
    validates :name, length: { maximum: 30 }
    validates :status, presence: true
    validate :deadline_is_today_or_later

    belongs_to :user
    has_and_belongs_to_many :labels

    def deadline_is_today_or_later
        if deadline.present? && deadline < Date.today
            errors.add(:deadline, 'は昨日以前の日付は設定できません')
        end
    end

    enum priority: { 低: 0, 中: 1, 高: 2 }
    # enum status:   { 未着手: 0, 着手中: 1, 完了済: 2 }

    def self.search(search)
        if search
            where(['status = ?', search])
        else
            all
        end
    end
end


