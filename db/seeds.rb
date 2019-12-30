# frozen_string_literal: true

# # 文字コード
# # coding: utf-8

# require 'csv'
# require 'seeds/seeds_helper'

# PaperTrail.enabled = false

# user = []
# CSV.foreach('db/user.csv', col_sep: ',', quote_char: '"', headers: false) do |row|
#   user << User.new(id: row[0], email: row[1], encrypted_password: row[2], creator_id: row[3])
# end
# User.import! user

# staff = []
# CSV.foreach('db/staff.csv', col_sep: ',', quote_char: '"', headers: false) do |row|
#   staff << Staff.new(id: row[0], user_id: row[1], name: row[2], name_ruby: row[3])
# end
# Staff.import! staff

# role = []
# CSV.foreach('db/role.csv', col_sep: ',', quote_char: '"', headers: false) do |row|
#   role << Role.new(id: row[0], name: row[1], kind: row[2].to_i)
# end
# Role.import! role

# staff_role = []
# CSV.foreach('db/staff_role.csv', col_sep: ',', quote_char: '"', headers: false) do |row|
#   staff_role << StaffRole.new(id: row[0], staff_id: row[1], role_id: row[2])
# end
# StaffRole.import! staff_role

# area = []
# CSV.foreach('db/area.csv', col_sep: ',', quote_char: '"', headers: false) do |row|
#   area << Area.new(id: row[0], name: row[1])
# end
# Area.import! area

# pref = []
# CSV.foreach('db/pref.csv', col_sep: ',', quote_char: '"', headers: false) do |row|
#   pref << Pref.new(id: row[0], area_id: row[1], name: row[2])
# end
# Pref.import! pref

# channel = []
# CSV.foreach('db/channel.csv', col_sep: ',', quote_char: '"', headers: false) do |row|
#   channel << Channel.new(
#     id: row[0],
#     name: row[1],
#     name_ruby: row[2],
#     guest_url: row[3],
#     admin_origin_url: row[4],
#     admin_login_path: row[5],
#     admin_reservation_path: row[6],
#     cookie_name: row[7]
#   )
# end
# Channel.import! channel

# selling_price_type = []
# CSV.foreach('db/selling_price_type.csv', col_sep: ',', quote_char: '"', headers: false) do |row|
#   selling_price_type << SellingPriceType.new(id: row[0], name: row[1], color: row[2])
# end
# SellingPriceType.import! selling_price_type

# customer_rank = []
# CSV.foreach('db/customer_rank.csv', col_sep: ',', quote_char: '"', headers: false) do |row|
#   customer_rank << CustomerRank.new(id: row[0], name: row[1])
# end
# CustomerRank.import! customer_rank

# account_category = []
# CSV.foreach('db/account_category.csv', col_sep: ',', quote_char: '"', headers: false) do |row|
#   account_category << AccountCategory.new(id: row[0], name: row[1], account_small_category_id: row[2])
# end
# AccountCategory.import! account_category

# account_small_category = []
# CSV.foreach('db/account_small_category.csv', col_sep: ',', quote_char: '"', headers: false) do |row|
#   account_small_category << AccountSmallCategory.new(id: row[0], name: row[1], account_middle_category_id: row[2])
# end
# AccountSmallCategory.import! account_small_category

# account_middle_category = []
# CSV.foreach('db/account_middle_category.csv', col_sep: ',', quote_char: '"', headers: false) do |row|
#   account_middle_category << AccountMiddleCategory.new(id: row[0], name: row[1], account_large_category_id: row[2])
# end
# AccountMiddleCategory.import! account_middle_category

# account_large_category = []
# CSV.foreach('db/account_large_category.csv', col_sep: ',', quote_char: '"', headers: false) do |row|
#   account_large_category << AccountLargeCategory.new(id: row[0], name: row[1])
# end
# AccountLargeCategory.import! account_large_category

# taxes = []
# CSV.foreach('db/consumption_tax.csv', col_sep: ',', quote_char: '"', headers: false) do |row|
#   taxes << ConsumptionTax.new(tax_rate: row[0], apply_from: row[1], apply_to: row[2])
# end
# ConsumptionTax.import! taxes

# return if Rails.env.production?

# room = []
# CSV.foreach('db/room.csv', col_sep: ',', quote_char: '"', headers: false) do |row|
#   room << Room.new(id: row[0], room_group_id: row[1], name: row[2], floor_id: row[3], cost: row[4] )
# end
# Room.import! room
#
# room_group = []
# CSV.foreach('db/room_group.csv', col_sep: ',', quote_char: '"', headers: false) do |row|
#   room_group << RoomGroup.new(id: row[0], name: row[1] )
# end
# RoomGroup.import! room_group
#
# vacant_room = []
# CSV.foreach('db/vacant_room.csv', col_sep: ',', quote_char: '"', headers: false) do |row|
#   vacant_room << VacantRoom.new(
#     id: row[0],
#     room_group_id: row[1],
#     date: row[2],
#     rooms_num: row[3]
#   )
# end
# VacantRoom.import! vacant_room
#
# customer = []
# CSV.foreach('db/customer.csv', col_sep: ',', quote_char: '"', headers: false) do |row|
#   customer << Customer.new(
#     id: row[0],
#     pref_id: row[1],
#     customer_rank_id: row[2],
#     last_dm_sent_at: row[3],
#     membership_number: row[4],
#     name: row[5],
#     name_ruby: row[6],
#     gender: row[7],
#     telephone1: row[8],
#     telephone2: row[9],
#     telephone3: row[10],
#     fax: row[11],
#     honorific: row[12],
#     zip_code: row[13],
#     address: row[14],
#     birthday: row[15],
#     email: row[16],
#     send_dm: row[17],
#     send_dm_destination: row[18],
#     work_place: row[19],
#     work_place_ruby: row[20],
#     work_place_telephone: row[21],
#     work_place_fax: row[22],
#     work_place_zip_code: row[23],
#     work_place_extension_number: row[24],
#     work_place_address: row[25],
#     work_place_note: row[26],
#     barcode_number: row[27],
#     repeat_willingness: row[28],
#     satisfaction: row[29],
#     dm_send_propriety: row[30]
#   )
# end
# Customer.import! customer
#
# item_group = []
# CSV.foreach('db/item_group.csv', col_sep: ',', quote_char: '"', headers: false) do |row|
#   item_group << ItemGroup.new(id: row[0], building_id: row[1], name: row[2])
# end
# ItemGroup.import! item_group
#
# plan = []
# CSV.foreach('db/plan.csv', col_sep: ',', quote_char: '"', headers: false) do |row|
#   plan << Plan.new(id: row[0], plan_group_id: row[1], channel_id: row[2], name: row[3])
# end
# Plan.import! plan
#
# plan_group = []
# CSV.foreach('db/plan_group.csv', col_sep: ',', quote_char: '"', headers: false) do |row|
#   plan_group << PlanGroup.new(id: row[0], name: row[1])
# end
# PlanGroup.import! plan_group
#
# dish_group = []
# CSV.foreach('db/dish_group.csv', col_sep: ',', quote_char: '"', headers: false) do |row|
#   dish_group << DishGroup.new(id: row[0], name: row[1])
# end
# DishGroup.import! dish_group
#
# option_group = []
# CSV.foreach('db/option_group.csv', col_sep: ',', quote_char: '"', headers: false) do |row|
#   option_group << OptionGroup.new(id: row[0], name: row[1])
# end
# OptionGroup.import! option_group
#
# reservation = []
# CSV.foreach('db/reservation.csv', col_sep: ',', quote_char: '"', headers: false) do |row|
#   reservation << Reservation.new(
#     id: row[0],
#     crawl_reservation_id: row[1],
#     room_group_id: row[2],
#     plan_id: row[3],
#     customer_id: row[4],
#     status: row[5],
#     route: row[6],
#     guest_name: row[7],
#     guest_name_ruby: row[8],
#     telephone: row[9],
#     email: row[10],
#     zip_code: row[11],
#     pref_id: row[12],
#     address: row[13],
#     rooms_num: row[14],
#     stay_days: row[15],
#     check_in_plan_at: row[16],
#     check_out_plan_at: row[17],
#     men_num: row[18],
#     women_num: row[19],
#     children_num: row[20],
#     guests_num: row[21],
#     question: row[22],
#     note: row[23],
#     add_price: row[24],
#     bill_price: row[25],
#     point: row[26],
#     kind_of_payment: row[27],
#     memo: row[28]
#   )
# end
# Reservation.import! reservation
#
# selling_calendar = []
# CSV.foreach('db/selling_calendar.csv', col_sep: ',', quote_char: '"', headers: false) do |row|
#   selling_calendar << SellingCalendar.new(
#     id: row[0],
#     plan_id: row[1],
#     room_group_id: row[2],
#     guests_num: row[3],
#     date: row[4],
#     set_price: row[5]
#   )
# end
# SellingCalendar.import! selling_calendar
#
# facility_group = []
# CSV.foreach('db/facility_group.csv', col_sep: ',', quote_char: '"', headers: false) do |row|
#   facility_group << FacilityGroup.new(
#     id: row[0],
#     building_id: row[1],
#     floor_id: row[2],
#     name: row[3]
#   )
# end
# FacilityGroup.import! facility_group
#
# facility = []
# CSV.foreach('db/facility.csv', col_sep: ',', quote_char: '"', headers: false) do |row|
#   facility << Facility.new(
#     id: row[0],
#     facility_group_id: row[1],
#     name: row[2],
#     capacity: row[3]
#   )
# end
# Facility.import! facility
