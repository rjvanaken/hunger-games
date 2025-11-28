import operations as ops

def prepare_num_for_update(value, attribute_name, min=None, max=None):
    """
    Takes an entered integer and converts it to an int or None if empty string
        Used for UPDATE calls in the database
    """
    if value == '' or value == 0:
        return None
    if value is not None:
        value = int(value)
        # Check range
        if min is not None and max is not None:
            if value < min or value > max:
                print(f"\n{attribute_name.Title()} must be in the range {min}-{max}")
                return False
        elif min is not None and value < min:
            print(f"\n{attribute_name.Title()} must be at least {min}")
            return False
        elif max is not None and value > max:
            print(f"\n{attribute_name.TItle()} must be at most {max}")
            return False
    return value


def prepare_name_for_update(name, max_length, attribute_name):
    """
        Takes in a name entered by user, validates it or sets to None if empty, and returns
        Used for UPDATE calls to the database
    """
    if name == '' or not name:
        return None
    if max_length and len(name) > max_length:
        print(f"\nMaximum characters for {attribute_name} is {max_length}")
        return False
    return name

def prepare_enum_for_update(value, list, attribute_name):
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