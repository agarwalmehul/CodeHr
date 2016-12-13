require 'set'

module ApplicationHelper
	def step_instance_processing(step_instance)
		eval("process_step_#{step_instance[:action]}(step_instance)")
		# step_instance.end_processing_step
	end

	def process_step_Fill(step_instance)
		puts "############################################################"
		puts "Fill Step"
		puts "############################################################"
		puts step_instance.to_json
		urlHelpers = Rails.application.routes.url_helpers

		initiator = User.find(step_instance.process_instance.initiator)
		title = step_instance['action_class']+" Creation"
		description = "Click here to Fill the Form"
		link = urlHelpers.new_generic_form_path(step_instance._id)
		initiator.send_task({title: title, description: description, link: link})
		# step_instance.end_processing_step
	end

	def process_step_Approve(step_instance)
		puts "############################################################"
		puts "Approve Step"
		puts "############################################################"
		puts step_instance.to_json


		step_instance.approval.send_tasks

	end

	def process_step_Notify(step_instance)
		puts "############################################################"
		puts "Notify Step"
		puts "############################################################"
		puts step_instance.to_json
		
		title = step_instance['action_obj']['title']
		description = step_instance['action_obj']['']
		step_instance['action_obj']['agents']['users'].each do |user_id|
			User.find(user_id).send_notification({title: title, description: description})
		end
		step_instance.end_processing_step
	end

	def process_step_MarkComplete(step_instance)
		puts "############################################################"
		puts "MarkComplete Step"
		puts "############################################################"
		puts step_instance.to_json
		fillStep = step_instance.get_previous_step({action: "Fill"})
		puts fillStep.to_json
		processed_form = process_step_MarkComplete_processing(fillStep['action_obj'])
		# eval(fillStep['action_class']).create!(fillStep['action_obj']['obj'])
		# step_instance.end_processing_step
	end

	def process_step_SpawnD(step_instance)
		puts "############################################################"
		puts "SpawnD Step"
		puts "############################################################"
		puts step_instance.to_json

		processInstance = ProcessInstance.new
		processInstance['process_master_id'] = step_instance.spawn_process
    processInstance['initiator'] = step_instance.process_instance.initiator
    processInstance['parent_process'] = step_instance.process_instance._id
    processInstance['parent_stepno'] = step_instance.sequence
    processInstance['spawn'] = true
    processInstance['dependent'] = true
    processInstance.build_process_instance 
		# step_instances.pawn_process
		# step_instance.end_processing_step
	end

	def process_step_SpawnI(step_instance)
		puts "############################################################"
		puts "SpawnI Step"
		puts "############################################################"
		puts step_instance.to_json

		processInstance = ProcessInstance.new
		processInstance['process_master_id'] = step_instance.spawn_process
    processInstance['initiator'] = step_instance.process_instance.initiator
    processInstance['parent_process'] = step_instance.process_instance._id
    processInstance['parent_stepno'] = step_instance.sequence
    processInstance['spawn'] = true
    processInstance.build_process_instance 

		step_instance.end_processing_step
	end

	def process_step_MarkComplete_processing(obj)
		form = eval(obj['action_class']).create!(obj['main_form'])
		form_confg = YAML::load_file("#{Rails.root}/config/forms/#{obj['action_class']}.yml")
		if obj['sub_forms']
			puts '------------------------------------------------- in if'
			obj['sub_forms'].each_with_index do |(key, value), index|
					subform = process_step_MarkComplete_processing(value)
					eval("form.#{form_confg['sub_forms'][index]['key']}") << subform
			end
		end
			
		form.save!
		
return form
	end
end