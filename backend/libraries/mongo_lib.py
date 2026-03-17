from bson import ObjectId
from pydantic import validate_call
from pymongo import MongoClient  # pip install pymongo

from libraries import environment_lib
from pymongo.collection import Collection
from pydantic import BaseModel

client: MongoClient


class MongoCollection(BaseModel):
    database: str
    collection: str


def initialize():
    connect()


def mongo_collection(path: MongoCollection) -> Collection:
    return get_client()[path.database][path.collection]


def connect() -> bool:
    global client

    credentials = environment_lib.get_mongodb_credentials()

    client = MongoClient(
        host=credentials.host,
        port=credentials.port,
        username=credentials.username,
        password=credentials.password,
        authMechanism='DEFAULT'
    )

    if client is None:
        return False

    return True


def get_client() -> MongoClient:
    if client is None:
        connect()

    return client


##############################
#     DATABASE FUNCTIONS     #
##############################

def get_databases() -> list[str]:
    return get_client().list_database_names()


@validate_call
def database_exists(database: str) -> bool:
    return database in get_client().list_database_names()


################################
#     COLLECTION FUNCTIONS     #
################################

@validate_call
def get_collections(database: str) -> list[str]:
    if not database_exists(database):
        return []

    return client[database].list_collection_names()


@validate_call
def collection_exists(database: str, collection: str) -> bool:
    if not database_exists(database):
        return False

    return collection in client[database].list_collection_names()


##########################
#     DATA FUNCTIONS     #
##########################

@validate_call
def item_exists(database: str, collection: str, item: str, value) -> bool:
    if not collection_exists(database, collection):
        return False

    return value in get_client()[database][collection].distinct(item)


def get_item(database: str, collection: str, item_id: str) -> dict:
    item = get_client()[database][collection].find_one({"_id": ObjectId(item_id)})
    if not item:
        return {}

    item['_id'] = str(item['_id'])
    return dict(item)


def collection_item(collection: Collection, item_id: str) -> dict:
    """
    Get item from collection
    :param collection: Cursor item which has navigated to desired collection
    :param item_id: _id of document
    :return: Item as dict and _id parsed to string
    """
    item = collection.find_one({"_id": ObjectId(item_id)})

    if not item:
        return {}

    item['_id'] = str(item['_id'])
    return dict(item)


def collection_items(collection: Collection, search: dict, field_filter: dict = None) -> list[dict]:
    """
    Get items from collection by search
    :param collection: Cursor item which has navigated to desired collection
    :param search: Get items by matching search: {'title': 'test'}
    :param field_filter: Only get fields of interest: {'title': 1} / {'panels': 0}
    :return: Items as list[dict] and _id parsed to string
    """
    items = list(collection.find(search, field_filter or {}))

    for item in items:
        item['_id'] = str(item['_id'])

    return items
