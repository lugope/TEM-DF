class MedicsController < ApplicationController

	def results
		@medics = Medic.search(params[:list_specility], params[:list_work_unit_name])
		if @medics
  			@medics
  		else
  			flash.now.alert="Escolha um campo."
  			render "home/index"
  		end
	end

	def profile
		@medic = Medic.find_by_id(params[:id])
		@work_unit = WorkUnit.find_by_id(@medic.work_unit_id)
		@average = calculate_average(@medic)
		@ratings = Rating.all.where(medic_id: @medic.id).size
	end

	def workunits_grath
		@medics_size = Array.new
		@unit_name = Array.new
		@work_unit = WorkUnit.all

		@work_unit.each do |work_unit|
			quantity = Medic.all.where(work_unit_id: work_unit.id).size
			@medics_size.push(quantity)
			@unit_name.push(work_unit.name)
		end
	end

	def rating
		medic_id = params[:medic_id]
		@user = User.find_by_id(session[:remember_token])
		@medic = Medic.find_by_id(medic_id)

		if @user != nil
			rating_status = ""

			@rating = Rating.find_by_user_id_and_medic_id(@user.id, @medic.id)

			if @rating != nil
				update_rating(@rating , params[:grade])
				rating_status = 'Avaliação Alterada!'
			else
				create_rating(@user, @medic)
				rating_status = 'Avaliação Realizada com sucesso!'
			end
			redirect_to action:"profile",id: medic_id, notice: rating_status
		else
			redirect_to login_path, :notice => "O Usuário necessita estar logado"
		end
	end

  	def create_comment
		@user = User.find_by_id(session[:remember_token])
		@medic = Medic.find_by_id(params[:medic_id])

		if @user
			@comment = Comment.new(content: params[:content], date: Time.now,
				medic: @medic, user: @user, comment_status: true, report: false)

			@comment.save
			redirect_to profile_path(@medic)
		else
			redirect_to login_path, :notice => "O Usuário necessita estar logado"
		end
  	end

  	def create_relevance
  		@user = User.find_by_id(session[:remember_token])
  		@comment = Comment.find_by_id(params[:comment_id])

		if @user == nil
			redirect_to login_path, :notice => "O Usuário necessita estar logado"
		elsif @comment
  			@relevance = Relevance.find_by_user_id_and_comment_id(@user.id, @comment.id)

  			if @relevance
  				@relevance.update_attribute(:value, params[:value])
  			else
  				@relevance = Relevance.create(value: params[:value], user: @user, comment: @comment)
  			end
			redirect_to action:"profile",id: params[:medic_id]
  		end
  	end

  	def to_report
  		@comment = Comment.find_by_id(params[:comment_id])
  		if @comment.report == false
  			@comment.update_attribute(:report, true)
  		end
  		flash[:alert] = "Comentario reportado."
		
  		redirect_to action:"profile",id: params[:medic_id]
  	end

  	private
  		def create_rating(user, medic)
			@rating = Rating.new(grade: params[:grade], user: user, medic: medic, date: Time.new)
			@rating.save
	  	end

	  	def update_rating(rating,grade)
	  		if grade != "0"
				rating.update_attribute(:grade , grade)
            	rating.update_attribute(:date , Time.new)
            end
	  	end

	  	def calculate_average(medic)
	  		@ratings = Rating.all.where(medic_id: medic.id)

	  		if @ratings.size == 0
	  			return 0
	  		else
		  		sum = 0
		  		@ratings.each do |r|
		  			sum += r.grade
	  			end

				return sum/(1.0*@ratings.size)
	  		end
	  	end
end
