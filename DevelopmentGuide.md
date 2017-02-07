# Development Guide



3.1. Developer guide: A document shall be provided which orients a new developer to how your system is constructed at a high level, what technologies are in use, how to configure a development/build environment, and how the database schema (or equivalent) is laid out.


Our software system, Spicy Software, is a web application built using the Ruby on Rails framework.

One key feature of the Ruby on Rails stack is that it favors convention over configuration, meaning that it provides users with default structures for a database and the web pages themselves. More specifically, Ruby on Rails operates under the Model-View-Controller (MVC) framework.

The ECE Inventory system is composed of several interacting model classes: these classes include the User, Item, Request, Tag, Log, Item-Tag, and Account Request classes.

The user, item, request, and tag models are directly mentioned in the handout, but the account request and log classes are two additional model classes created to satisfy the requirements. Account Requests are used so that the admin can approve users before they begin using the inventory app. On the other hand, logs are used to track each transaction that ever takes place (including disembursements that require no request from a user).

The database used by Spicy Software Inc. is PostSQL, but in this project, database operations are performed by ActiveRecord, which provides default database operations without having the user to interact with the database directly.

The database consists of tables with the model classes as the primary (lookup) key. The fields of these tables include all the fields of the model classes. Table 1 below displays each model class along with its attributes, such that there is a table for each model class. For instance, the fields of the item class include the unique name, model number, quantity, location, and the description of the item. 

| Model Class |                                                       Fields                                                       |
|-------------|:------------------------------------------------------------------------------------------------------------------:|
| User        | username, created_at, updated_at, password_digest, email, email_confirmed, confirm_token, status, privilege, email |
| Item        | unique_name, quantity, model_number, description, location                                                         |
| Request     | datetime, user_id, quantity, reason, instances, created_at, updated_at, status, request_type, item_id, response     |
| Tag         | name, created_at, updated_at                                                                                       |
| Item_Tags   | tag_id, item_id, created_at, updated_at                                                                            |
| Logs        | quantity, created_at, updated_at, request_type, item_id, user_id                                          |

In many cases, a table contains a field that is already a model class. For instance, the Request table contains the fields item_id and user_id. In these cases, a foreign key relation is established to speed-up the lookup of an item in the request table.  

Object associations set up in this database include an association between the Tag, Item_Tags, and Item models. In addition, there exists a mutual has-many relationship between items and requests, as well as between users and requests, meaning that an item can have 0 to many requests and vice versa. Finally, each log contains a single user and a single item.
 
Steps for Deployment? Maybe include things from the deployment guide?