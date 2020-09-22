from skdecide import utils
from sqlalchemy import create_engine

connection_str = 'postgresql://docker:docker@localhost/gis'
engine = create_engine (connection_str, echo=True)