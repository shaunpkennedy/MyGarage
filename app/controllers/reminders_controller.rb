class RemindersController < ApplicationController
  before_action :authenticate!
  before_action :set_vehicle
  before_action :set_reminder, only: %i[show edit update destroy complete]

  def index
    @active_reminders = @vehicle.reminders.active.includes(:service_type, :reminder_type)
    @completed_reminders = @vehicle.reminders.completed.includes(:service_type, :reminder_type).order(completed_at: :desc)
  end

  def show
  end

  def new
    @reminder = @vehicle.reminders.build
  end

  def create
    @reminder = @vehicle.reminders.build(reminder_params)

    if @reminder.save
      flash[:notice] = 'Reminder created.'
      redirect_to vehicle_path(@vehicle)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @reminder.update(reminder_params)
      flash[:notice] = 'Reminder updated.'
      redirect_to vehicle_reminders_path(@vehicle)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @reminder.destroy
    flash[:notice] = 'Reminder removed.'
    redirect_to vehicle_reminders_path(@vehicle)
  end

  def complete
    @reminder.complete!
    flash[:notice] = "#{@reminder.service_type.name} marked as completed."
    redirect_to vehicle_path(@vehicle)
  end

  private

  def set_vehicle
    @vehicle = current_user.vehicles.find(params[:vehicle_id])
  end

  def set_reminder
    @reminder = @vehicle.reminders.find(params[:id])
  end

  def reminder_params
    params.require(:reminder).permit(
      :service_type_id, :reminder_type_id, :miles, :time,
      :next_odometer, :notes
    )
  end
end
