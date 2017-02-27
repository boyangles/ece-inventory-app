# Development Guide

Our software, the Spicy Software ECE Inventory System, is a web application built using the Ruby on Rails framework.

One key feature of the Ruby on Rails stack is that it favors convention over configuration, meaning that it provides users with default structures for a database and the web pages themselves, based on the Model-View-Controller (MVC) framework.

The database used by Spicy Software Inc. is PostSQL, but main database operations are performed by ActiveRecord, which provides default database operations without having the user to interact with the database directly.

The ECE Inventory system is composed of several interacting model classes, listed in the table below.


The database consists of tables with the model classes as the primary (lookup) key. The fields of these tables include all the fields of the model classes. Table 1 below displays each model class along with its attributes, such that there is a table for each model class. For instance, the fields of the item class include the unique name, model number, quantity, location, and the description of the item. 

| Model Class |                                                       Fields                                                       |
|-------------|:------------------------------------------------------------------------------------------------------------------:|
| User        | username, created_at, updated_at, password_digest, email, confirm_token, status, privilege, auth_token |
| Item        | unique_name, quantity, model_number, description, location, status, last_action                                                         |
| Custom_Fields | field_name, private_indicator, field_type | 
| Item_Custom_Fields | item_id, custom_field_id, short_text_content, long_text_content, integer_content, float_content|
| Tags         | name, created_at, updated_at                                                                                       |
| Item_Tags   | tag_id, item_id, created_at, updated_at                                                                            |
| Requests     | reason, created_at, updated_at, status, request_type, response, user_id   |
| Request_Items | request_id, item_id, created_at, updated_at, quantity|
| Logs        | created_at, updated_at, request_type, user_id, log_type|
| Item_Logs | log_id, item_id, action, quantity_change, old_name, new_name, old_desc, new_desc, old_model_num, new_model_num, curr_quantity |
| User_Logs | log_id, user_id, action, old_privilege, new_privilege |
| Request_Logs | log_id, request_id, action |
| Stack_Exchanges | created_at, updated_at |

The user, item, request, and tag models are directly mentioned in the handout, but the account request and log classes are two additional model classes created to satisfy the requirements. Account Requests allow the admin to approve users before they begin using the inventory app; logs track every transaction that ever takes place (including updates to the request statuses and disembursements that require no request from a user).

Below we will briefly describe the use of each case in our project, their associations, and describe their fields.

### Users

### Items

### Custom_Fields

### Item_Custom_Fields

### Tags

### Item_Tags

### Requests

### Request_Items

### Logs

### Item_Logs

### User_Logs

### Request_Logs

### Stack Exchanges
