class GenericsController < InheritedResources::Base

	def new
		@generic = Generic.new
		@form_title = "Fill Form - Document Creation"
		
	end

	def create
		render :text => params
		return
		
	end

  private

    # def generic_params
    #   params.require(:generic).permit()
    # end
end

