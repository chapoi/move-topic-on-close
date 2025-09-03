# frozen_string_literal: true

# name: automation-move-topic-on-close
# about: A custom script for Discourse automation
# meta_topic_id: TODO
# version: 0.0.1
# authors: Chapoi
# url: TODO
# required_version: 2.7.0

enabled_site_setting :automation_move_topic_on_close_enabled

module ::AutomationMoveTopicOnClose
  PLUGIN_NAME = "automation_move_topic_on_close"
end

after_initialize do
  reloadable_patch do
    if defined?(DiscourseAutomation)
      DiscourseAutomation::Scriptable.add(:move_topic_on_close) do
        field :source_category, component: :category, required: true
        field :target_category, component: :category, required: true

        version 1

        triggerables %i[topic_closed]

        script do |context, fields|
          topic = context["topic"]

          Rails.logger.info("Automation triggered! Context: #{context.inspect}")

          source_category_id = fields.dig("source_category", "value")
          target_category_id = fields.dig("target_category", "value")

          next unless topic.category_id == source_category_id

          topic.category_id = target_category_id
          topic.save!

          Rails.logger.info("Moved topic #{topic.id} from category #{source_category_id} to #{target_category_id}")
        end
      end
    end
  end
end
