class TransactionsController < ApplicationController
    before_action :authenticate_user!

    def new
    @transaction = Transaction.new
    end
end
