Shoes.app(width:2000 , height:1000) do 
    edit_box "Heyyya" 
    para "hi there"

    edit_box "cool but i am bigger and better!!", width: 500, height: 300,wrap_mode: :none
    para "    "
    edit_box "okay but i have good wrapping!! unlike u 🫢", width: 100, height: 300,wrap_mode: :word
    para "   "
    edit_box "oh... i.. dont have a wrap", width: 100, height: 300,wrap_mode: :none
    para "    "
    edit_box "oh oh okay cool cool how about this? try editing me ? can u? u can't hahahaa" , editable: false
    para "    "
    edit_box "lol okay.. i am editable and i am superior i can even hide my cursor!!" , cursor_visible: false

    para "    "
    edit_box "lol stupid kids but.. i have more personal space see i can float"  , padding_bottom:80, padding_top:200,padding_right:50  

end