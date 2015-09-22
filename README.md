# Final-app-P5
final app P5
Final app nanodegree iOS Developer
The WhereIsTheCar? app it´s intended to help those people like me that share car with other memebers of the family or friends, 
or even companies who have pull-cars to share. With this app you can create users and asign them to an especific car. Only one 
user can be driving and all the other users can see who is driving. Whenever some park the car, the geo-location of
the car is saved so everyone can see where the car is and if it is available for them. A map will be display with the user´s 
position and the car´s position so it will make it easier for them to find it and not to have to call everyone asking 
"where is the car?"

Parse API - CoreData - Segue - Modal - Navigation 

The first screen will let you login or sign up to create an account. Once you are log in it will be four options:
1.- Park
2.- Drive
3.- Settings
4.- List of users of that car

The first time you login you will have to provide a car id, if the car already exists you will be asign to it, if not 
a new car will be created.
1.- Park
If you touch Park and you are driving, you will be able to park the car and store online his location.
If you are not driving it you will not be able to do it an a message will appear on screeen indicaiting it.
2.- Drive
You will see a map and a indicator of the car position and his state, if the car is availbale you will be able to touch
Drive and the car will be on your hands.
If the car is not free a message indicating who is using it will appear on screen telling you who is driving it
3.- Settings 
You will have a switch with the option to keep you log in, that information will be store using core data so the next
time you will run the app after login out your information will be already on screen(user and password) so you just need to 
touch login button.
4.- List of users
A table view controller will show the users assign to the car you are assign to. A message on the rigth side
will indicate who is the one driving the car at the moment or nothing if no one is driving the car.
