Factory.define :guest_order do |f|
  f.username = 'phildionne'
  f.password = '123456789'
  f.product  = 'surfboard'
end

Factory.define :invalid_guest_order, class: 'GuestOrder' do |f|
  f.username = nil
  f.password = nil
  f.product  = nil
end
