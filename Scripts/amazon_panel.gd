extends Panel

var cart = {}  # Dictionary to hold items in the cart
var item_prices = {  # Set prices for each item
	"Bobby Pins": 5,
	"Ballpoint Pen": 10,
	"Scissors": 20,
	"Digital Camera": 50,
	"Voice Recorder": 60,
	"Trail Camera": 120,
	"IntBook1": 50,
	"SocBook1": 50,
	"StlBook1": 50,
	"IntBook2": 100,
	"SocBook2": 100,
	"StlBook2": 100,
	"IntBook3": 200,
	"SocBook3": 200,
	"StlBook3": 200,
	"IntBook4": 300,
	"SocBook4": 300,
	"StlBook4": 300,
	# Add more items as needed
}
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if $HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer/IntBook1.disabled:
		$HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer/IntBook1.text = "IntBook1
+ 1 Intelligence
$50.00
Sold Out"
	else:
		$HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer/IntBook1.text = "IntBook1
+ 1 Intelligence
$50.00
Add to Cart"
	if $HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer/SocBook1.disabled:
		$HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer/SocBook1.text = "SocBook1
+ 1 Social
$50.00
Sold Out"
	else:
		$HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer/SocBook1.text = "SocBook1
+ 1 Social
$50.00
Add to Cart"
	if $HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer/StlBook1.disabled:
		$HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer/StlBook1.text = "StlBook1
+ 1 Stealth
$50.00
Sold Out"
	else:
		$HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer/StlBook1.text = "StlBook1
+ 1 Stealth
$50.00
Add to Cart"
	if $HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer/IntBook2.disabled:
		$HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer/IntBook2.text = "IntBook2
+ 2 Intelligence
$100.00
Sold Out"
	else:
		$HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer/IntBook2.text = "IntBook2
+ 2 Intelligence
$100.00
Add to Cart"
	if $HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer/SocBook2.disabled:
		$HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer/SocBook2.text = "SocBook2
+ 2 Social
$100.00
Sold Out"
	else:
		$HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer/SocBook2.text = "SocBook2
+ 2 Social
$100.00
Add to Cart"
	if $HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer/StlBook2.disabled:
		$HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer/StlBook2.text = "StlBook2
+ 2 Stealth
$100.00
Sold Out"
	else:
		$HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer/StlBook2.text = "StlBook2
+ 2 Stealth
$100.00
Add to Cart"
	if $HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer2/IntBook3.disabled:
		$HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer2/IntBook3.text = "IntBook3
+ 3 Intelligence
$200.00
Sold Out"
	else:
		$HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer2/IntBook3.text = "IntBook3
+ 3 Intelligence
$200.00
Add to Cart"
	if $HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer2/SocBook3.disabled:
		$HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer2/SocBook3.text = "SocBook3
+ 3 Social
$200.00
Sold Out"
	else:
		$HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer2/SocBook3.text = "SocBook3
+ 3 Social
$200.00
Add to Cart"
	if $HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer2/StlBook3.disabled:
		$HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer2/StlBook3.text = "StlBook3
+ 3 Stealth
$200.00
Sold Out"
	else:
		$HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer2/StlBook3.text = "StlBook3
+ 3 Stealth
$200.00
Add to Cart"
	if $HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer2/IntBook4.disabled:
		$HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer2/IntBook4.text = "IntBook4
+ 4 Intelligence
$300.00
Sold Out"
	else:
		$HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer2/IntBook4.text = "IntBook4
+ 4 Intelligence
$300.00
Add to Cart"
	if $HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer2/SocBook4.disabled:
		$HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer2/SocBook4.text = "SocBook4
+ 4 Social
$300.00
Sold Out"
	else:
		$HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer2/SocBook4.text = "SocBook4
+ 4 Social
$300.00
Add to Cart"
	if $HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer2/StlBook4.disabled:
		$HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer2/StlBook4.text = "StlBook4
+ 4 Stealth
$300.00
Sold Out"
	else:
		$HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer2/StlBook4.text = "StlBook4
+ 4 Stealth
$300.00
Add to Cart"


	if $HBoxContainer/VBoxContainer2/HBoxContainer/VBoxContainer/BallPen.disabled:
		$HBoxContainer/VBoxContainer2/HBoxContainer/VBoxContainer/BallPen.text = "Ballpoint Pen

$10.00
Sold Out"
	else:
		$HBoxContainer/VBoxContainer2/HBoxContainer/VBoxContainer/BallPen.text = "Ballpoint Pen

$10.00
Add to Cart"
	if $HBoxContainer/VBoxContainer2/HBoxContainer/VBoxContainer/Scissors.disabled:
		$HBoxContainer/VBoxContainer2/HBoxContainer/VBoxContainer/Scissors.text = "Scissors

$20.00
Sold Out"
	else:
		$HBoxContainer/VBoxContainer2/HBoxContainer/VBoxContainer/Scissors.text = "Scissors

$20.00
Add to Cart"
	if $HBoxContainer/VBoxContainer2/HBoxContainer/VBoxContainer/DigCamera.disabled:
		$HBoxContainer/VBoxContainer2/HBoxContainer/VBoxContainer/DigCamera.text = "Digital Camera

$50.00
Sold Out"
	else:
		$HBoxContainer/VBoxContainer2/HBoxContainer/VBoxContainer/DigCamera.text = "Digital Camera

$50.00
Add to Cart"
	if $HBoxContainer/VBoxContainer2/HBoxContainer/VBoxContainer/VoiceRec.disabled:
		$HBoxContainer/VBoxContainer2/HBoxContainer/VBoxContainer/VoiceRec.text = "Voice Recorder

$60.00
Sold Out"
	else:
		$HBoxContainer/VBoxContainer2/HBoxContainer/VBoxContainer/VoiceRec.text = "Voice Recorder

$60.00
Add to Cart"
	if $HBoxContainer/VBoxContainer2/HBoxContainer/VBoxContainer/TrailCam.disabled:
		$HBoxContainer/VBoxContainer2/HBoxContainer/VBoxContainer/TrailCam.text = "Trail Camera

$120.00
Sold Out"
	else:
		$HBoxContainer/VBoxContainer2/HBoxContainer/VBoxContainer/TrailCam.text = "Trail Camera

$120.00
Add to Cart"

func _on_cart_button_pressed():
	$CartPanel.visible = true

func _on_close_cart_button_pressed():
	$CartPanel.visible = false

func _on_int_book_1_pressed():
	if cart.size() >= 10:
		return  # Exit the function if the cart is full
	add_to_cart("IntBook1")
	$HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer/IntBook1.disabled = true

func _on_soc_book_1_pressed():
	if cart.size() >= 10:
		return  # Exit the function if the cart is full
	add_to_cart("SocBook1")
	$HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer/SocBook1.disabled = true

func _on_stl_book_1_pressed():
	if cart.size() >= 10:
		return  # Exit the function if the cart is full
	add_to_cart("StlBook1")
	$HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer/StlBook1.disabled = true

func _on_int_book_2_pressed():
	if cart.size() >= 10:
		return  # Exit the function if the cart is full
	add_to_cart("IntBook2")
	$HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer/IntBook2.disabled = true

func _on_soc_book_2_pressed():
	if cart.size() >= 10:
		return  # Exit the function if the cart is full
	add_to_cart("SocBook2")
	$HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer/SocBook2.disabled = true

func _on_stl_book_2_pressed():
	if cart.size() >= 10:
		return  # Exit the function if the cart is full
	add_to_cart("StlBook2")
	$HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer/StlBook2.disabled = true

func _on_int_book_3_pressed():
	if cart.size() >= 10:
		return  # Exit the function if the cart is full
	add_to_cart("IntBook3")
	$HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer2/IntBook3.disabled = true

func _on_soc_book_3_pressed():
	if cart.size() >= 10:
		return  # Exit the function if the cart is full
	add_to_cart("SocBook3")
	$HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer2/SocBook3.disabled = true

func _on_stl_book_3_pressed():
	if cart.size() >= 10:
		return  # Exit the function if the cart is full
	add_to_cart("StlBook3")
	$HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer2/StlBook3.disabled = true

func _on_int_book_4_pressed():
	if cart.size() >= 10:
		return  # Exit the function if the cart is full
	add_to_cart("IntBook4")
	$HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer2/IntBook4.disabled = true

func _on_soc_book_4_pressed():
	if cart.size() >= 10:
		return  # Exit the function if the cart is full
	add_to_cart("SocBook4")
	$HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer2/SocBook4.disabled = true

func _on_stl_book_4_pressed():
	if cart.size() >= 10:
		return  # Exit the function if the cart is full
	add_to_cart("StlBook4")
	$HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer2/StlBook4.disabled = true

func _on_bobby_pins_pressed():
	add_to_cart("Bobby Pins")

func _on_ball_pen_pressed():
	if cart.size() >= 10:
		return  # Exit the function if the cart is full
	add_to_cart("Ballpoint Pen")
	$HBoxContainer/VBoxContainer2/HBoxContainer/VBoxContainer/BallPen.disabled = true

func _on_scissors_pressed():
	if cart.size() >= 10:
		return  # Exit the function if the cart is full
	add_to_cart("Scissors")
	$HBoxContainer/VBoxContainer2/HBoxContainer/VBoxContainer/Scissors.disabled = true

func _on_dig_camera_pressed():
	if cart.size() >= 10:
		return  # Exit the function if the cart is full
	add_to_cart("Digital Camera")
	$HBoxContainer/VBoxContainer2/HBoxContainer/VBoxContainer/DigCamera.disabled = true

func _on_voice_rec_pressed():
	if cart.size() >= 10:
		return  # Exit the function if the cart is full
	add_to_cart("Voice Recorder")
	$HBoxContainer/VBoxContainer2/HBoxContainer/VBoxContainer/VoiceRec.disabled = true

func _on_trail_cam_pressed():
	if cart.size() >= 10:
		return  # Exit the function if the cart is full
	add_to_cart("Trail Camera")
	$HBoxContainer/VBoxContainer2/HBoxContainer/VBoxContainer/TrailCam.disabled = true

func get_button_for_item(item_name: String) -> Button:
	match item_name:
		"IntBook1": return $HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer/IntBook1
		"SocBook1": return $HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer/SocBook1
		"StlBook1": return $HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer/StlBook1
		"IntBook2": return $HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer/IntBook2
		"SocBook2": return $HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer/SocBook2
		"StlBook2": return $HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer/StlBook2
		"IntBook3": return $HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer2/IntBook3
		"SocBook3": return $HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer2/SocBook3
		"StlBook3": return $HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer2/StlBook3
		"IntBook4": return $HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer2/IntBook4
		"SocBook4": return $HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer2/SocBook4
		"StlBook4": return $HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer2/StlBook4
		"Bobby Pins": return $HBoxContainer/VBoxContainer2/HBoxContainer/VBoxContainer/BobbyPins
		"Ballpoint Pen": return $HBoxContainer/VBoxContainer2/HBoxContainer/VBoxContainer/BallPen
		"Scissors": return $HBoxContainer/VBoxContainer2/HBoxContainer/VBoxContainer/Scissors
		"Digital Camera": return $HBoxContainer/VBoxContainer2/HBoxContainer/VBoxContainer/DigCamera
		"Voice Recorder": return $HBoxContainer/VBoxContainer2/HBoxContainer/VBoxContainer/VoiceRec
		"Trail Camera": return $HBoxContainer/VBoxContainer2/HBoxContainer/VBoxContainer/TrailCam
		_:
			print("Warning: No button found for item:", item_name)
			return null

func _on_visibility_changed():
	_on_clear_cart_button_pressed()
	for item_name in Globals.item_stock.keys():
		var button = get_button_for_item(item_name)
		if Globals.item_stock[item_name] == 0:
			button.disabled = true
		elif cart.has(item_name) and cart[item_name]["in_cart"]:
			button.disabled = true  # Disable if already in the cart
		else:
			button.disabled = false  # Enable if in stock and not in the cart

func add_to_cart(item_name: String):
	# Check stock first
	var stock = Globals.item_stock[item_name]
	if stock == 0:
		print("Item out of stock!")
		return
	
	# Get the item's category from Globals
	var category = Globals.item_categories[item_name]

	# Add item to cart or update quantity if it's already in the cart
	if cart.has(item_name):
		cart[item_name]["quantity"] += 1
	else:
		if cart.size() >= 10:
			print("Cart is full! Cannot add more items.")
			return  # Exit the function if the cart is full
		cart[item_name] = {
			"quantity": 1,
			"price": item_prices[item_name],
			"category": category,
			"in_cart": true,
		}
	update_cart_display()
	print(item_name, " added to cart.")

func update_cart_display():
	var total_cost = 0
	var index = 0

	# Clear all labels in VBoxContainers before updating
	for i in range(10):
		$CartPanel/VBoxContainer/HBoxContainer/VBoxContainer.get_node("Label" + str(i + 1)).text = ""
		$CartPanel/VBoxContainer/HBoxContainer/VBoxContainer2.get_node("Label" + str(i + 1)).text = ""
		$CartPanel/VBoxContainer/HBoxContainer/VBoxContainer3.get_node("Label" + str(i + 1)).text = ""

	# Populate labels with cart items
	for item_name in cart.keys():
		if index < 10:
			var quantity = cart[item_name]["quantity"]
			var price = cart[item_name]["price"] * quantity
			total_cost += price

			# Update labels for each item
			$CartPanel/VBoxContainer/HBoxContainer/VBoxContainer.get_node("Label" + str(index + 1)).text = item_name
			$CartPanel/VBoxContainer/HBoxContainer/VBoxContainer2.get_node("Label" + str(index + 1)).text = "Qty: " + str(quantity)
			$CartPanel/VBoxContainer/HBoxContainer/VBoxContainer3.get_node("Label" + str(index + 1)).text = "$" + str(price)
			index += 1

	# Update the total cost in Label11 of VBoxContainer3
	$CartPanel/VBoxContainer/HBoxContainer/VBoxContainer2/Label11.text = "\n" + "$" + str(total_cost)

func purchase_items():
	var total_cost = float($CartPanel/VBoxContainer/HBoxContainer/VBoxContainer2/Label11.text.split("$")[1])  # Extract total cost from Label11
	if Globals.player_money >= total_cost:
		Globals.decrease_player_money(total_cost)
		var items_to_deliver = {}
		for item_name in cart.keys():
			items_to_deliver[item_name] = { "quantity": cart[item_name]["quantity"] }
			if Globals.item_stock[item_name] > 0:
				Globals.item_stock[item_name] -= 1
				print(item_name, " remaining stock: ", Globals.item_stock[item_name])
		var order_date = {
			"day": UI.current_day,
			"month": UI.current_month,
			"year": UI.current_year,
			"day_index": UI.current_day_index
		}
		Globals.schedule_delivery(items_to_deliver, order_date)
		cart.clear()  # Clear the cart
		update_cart_display()  # Refresh the cart UI to reflect empty cart
		$CartPanel.visible = false
		$PurchaseAudio.play()
		print("Purchase successful! Remaining funds: $", Globals.player_money)
		print("Delivery queued:", Globals.delivery_queue)
	else:
		print("Not enough funds to complete purchase.")

func _on_order_button_pressed():
	purchase_items()

func _on_clear_cart_button_pressed():
	for item_name in cart.keys():
		var button = get_button_for_item(item_name)
		cart[item_name]["in_cart"] = false  # Reset in_cart flag
		if Globals.item_stock[item_name] != 0:
			button.disabled = false
		else:
			button.disabled = true

	cart.clear()  # Clear the cart
	update_cart_display()
	$CartPanel.visible = false
