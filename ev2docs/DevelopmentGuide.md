# Development Guide

Our software, the Spicy Software ECE Inventory System, is a web application built using the Ruby on Rails framework.

One key feature of the Ruby on Rails stack is that it favors convention over configuration, meaning that it provides users with default structures for a database and the web pages themselves, based on the Model-View-Controller (MVC) framework.

The database used by Spicy Software Inc. is PostSQL, but main database operations are performed by ActiveRecord, which provides default database operations without having the user to interact with the database directly.

The ECE Inventory system is composed of several interacting model classes, listed in the table below.


The database consists of tables with the model classes as the primary (lookup) key. The fields of these tables include all the fields of the model classes. Table 1 below displays each model class along with its attributes, such that there is a table for each model class. For instance, the fields of the item class include the unique name, model number, quantity, location, and the description of the item. 

| Model Class |                                                       Fields                                                       |
|-------------|:------------------------------------------------------------------------------------------------------------------:|
| User        | username, password_digest, email, created_at, updated_at, status, privilege, auth_token |
| Item        | unique_name, quantity, model_number, description, location, status, last_action                                                         |
| Custom_Fields | field_name, private_indicator, field_type | 
| Item_Custom_Fields | item_id, custom_field_id, short_text_content, long_text_content, integer_content, float_content|
| Tag         | name                                                                                    |
| Item_Tags   | tag_id, item_id                                                                            |
|Request     | reason, created_at, updated_at, status, request_type, response, user_id   |
| Request_Items | request_id, item_id, created_at, updated_at, quantity|
| Logs        | created_at, updated_at, request_type, user_id, log_type|
| Item_Logs | log_id, item_id, action, quantity_change, old_name, new_name, old_desc, new_desc, old_model_num, new_model_num, curr_quantity |
| User_Logs | log_id, user_id, action, old_privilege, new_privilege |
| Request_Logs | log_id, request_id, action |
| Stack_Exchanges | created_at, updated_at |

The user, item, request, and tag models are directly mentioned in the handout, but the account request and log classes are two additional model classes created to satisfy the requirements. Account Requests allow the admin to approve users before they begin using the inventory app; logs track every transaction that ever takes place (including updates to the request statuses and disembursements that require no request from a user).

In many cases, a table contains a field that is already a model class. For instance, the Request table contains the fields item_id and user_id. In these cases, a foreign key relation is established to speed-up the lookup of an item in the request table.  

Below we will briefly describe the use of each case in our project and describe their fields.

### Users

A user instance is created for every user in the system, whether their accounts are locally created by admin or linked with a NetID Oauth account. 

##### FIELDS
* **username** - This field must be unique, and is the name displayed with the user on the UI. It is specified by the administrator or it is the NetID of the student. 
* **password_digest** - This is the salted and hashed version of each user's password.
* **created_at**/**updated_at** - These are fields created and maintained by the system, and can be used in logging that note the most recent time the user was created or updated, respectively.
* **email** - Emails are required to be unique. In Evolution 1, we used the email in order to confirm user accounts. This evolution, this functionality has been stripped in favor of the OAuth extensions, but we maintain this record because we foresee that future functionalities may be enhanced by email capabilities. We do require that emails have the *@duke.edu* extension.
* **privilege** - There are three possible enums for privilege: student, manager, and admin. Privileges determine the level of access the users have in the system. Privileges are nested, and will be discussed in more detail later in this guide.
* **status** - By default, users are "approved" when their accounts are created. If at any time in the future, admins or managers desire to deactivate users, that functionality is available. Deactivated users will not be able to login to their accounts at all, and therefore cannot access the system; nevertheless, their records will persist.
* **auth_token** - 

##### ASSOCIATIONS
* has-many REQUESTS
* has-many USER_LOGS

### Items
Each item instance represents a type of equipment in the inventory system. Items can be created and edited by managers or administrators. 
##### FIELDS
* **unique_name** - This is the name given to an item. As the name suggests, it must be unique. This is the name displayed in the UI for readability.
* **quantity** - This field notes the quantity of the item that is currently in the inventory. This must be an integer.
* **model_number**/**description** - These two fields enhance and provide a further description of each item beyond its name. 
* **location** - This field informs a user of the current location of the item in question.
* **status** - An item can either be active or deactive. A deactive item cannot be requested, disbursed, etc. However, its logged record is maintained and is viewable by administrators. An active item can be subject to all the requirements of this inventory system.
* **last_action** - This field was provided to provide information when logging quantity changes. In this way, quantity can be updated in both the items and requests controller (when an item is in a request that is approved, the quantity in the inventory is updated), but logging can stay automatic within the model. 

##### ASSOCIATIONS
* has-many TAGS, through ITEM_TAGS
* has-many ITEM_TAGS
* has-many REQUESTS, through REQUEST_ITEMS
* has-many REQUEST_ITEMS
* has-many CUSTOM_FIELDS, through ITEM_CUSTOM_FIELDS
* has-many ITEM_CUSTOM_FIELDS

### Tags
Tags help classify items, and are created by administrators. Items are searchable via their tags. 
##### FIELDS
* **name** - This is the unique name that identifies a tag and will be what users use to search for relevant equipment. 

##### ASSOCIATIONS
* has-many ITEMS, through ITEM_TAGS
* has-many ITEM_TAGS

### Item_Tags
Item tags exist to keep track of the many relationships between various items and tags, as there exists a many-to-many relationship between the two items. 

##### FIELDS
* **item_id/tag_id** - Keeps track of the specific item and tag which are associated.

##### ASSOCIATIONS
* belongs-to ITEMS
* belongs-to TAGS

### Custom_Fields
##### FIELDS

##### ASSOCIATIONS


### Item_Custom_Fields
##### FIELDS

##### ASSOCIATIONS

### Requests
##### FIELDS

##### ASSOCIATIONS

### Request_Items
##### FIELDS

##### ASSOCIATIONS

### Logs
##### FIELDS

##### ASSOCIATIONS

### Item_Logs
##### FIELDS

##### ASSOCIATIONS

### User_Logs
##### FIELDS

##### ASSOCIATIONS

### Request_Logs
##### FIELDS

##### ASSOCIATIONS

### Stack Exchanges
##### FIELDS

##### ASSOCIATIONS


 
## Deployment

Please refer to the our [deployment guide](DeploymentGuide.md). 

## Within System Rules
### Privileges
