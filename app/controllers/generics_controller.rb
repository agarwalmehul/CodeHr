class GenericsController < InheritedResources::Base

	def new
		@generic = Generic.new
		@step_instance = StepInstance.find(params[:step_id])
		@model = @step_instance[:action_class]

		# @model = "Document"
		# @step_instance = {_id: "111"}
		@form = Generic.find_by(model: @step_instance[:action_class])

		gon.form = @form
		
	end

	def create
		# render :text => params
		# return

		step_instance = StepInstance.find(params['step'])
		step_instance['action_obj'] = {obj: params['form'].to_s}
		# render :text => params['form']
		# return
		step_instance.save!
		step_instance.end_processing_step
		redirect_to root_path

		
	end

  private

    # def generic_params
    #   params.require(:generic).permit()
    # end
end

