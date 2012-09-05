class ReportBugsController < ApplicationController
  def create
    check_param :browser
    check_param :description

    StaffMailer.report_bug(
        current_user, params[:browser], params[:description]).deliver

    respond_to do |format|
      format.json { render :json => {} }
    end
  end
end
