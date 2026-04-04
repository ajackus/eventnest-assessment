class AddFailureReasonToPayments < ActiveRecord::Migration[7.1]
  def change
    add_column :payments, :failure_reason, :string
  end
end
