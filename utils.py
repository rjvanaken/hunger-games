import operations as ops

def prepare_number_for_update(number, min, max, attribute_name):
    """Takes an entered integer and converts it to an int or None if empty string
        Used for UPDATE calls in the database
    """
    if number == '':
        number= None
    elif number is not None:
        number = int(number)
    if number is not None and (number < min or number > max):
        print(f"\n{attribute_name} must be in the range {min}-{max}")
        return False
    
    return number


def prepare_name_for_update(name, max_length):
    """
        Takes in a name entered by user, validates it or sets to None if empty, and returns
        Used for UPDATE calls to the database
    """
    if name == '' or not name:
        return None
    if max_length and len(name) > max_length:
        return False
    return name

def prepare_enum_for_update(value, list, attribute_name)
    """
    Takes in an enum entered by user, verifies it's a valid option or sets to None if empty, and returns
    Used for UPDATE calls to the database
    """
    if value is not None and value != '':
        value = value.lower()
        if value not in list:
            print(f"\n{attribute_name.Title()} must be one of the following: {list}")
            return False
    else:
        value = None;
    
    return value
    
def prepare_date_for_update(date):
    if date is not None and date != '':
        date = ops.validate_and_convert_date(date)
    else:
        date = None
    return date