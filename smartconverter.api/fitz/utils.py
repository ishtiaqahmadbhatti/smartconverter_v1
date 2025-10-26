"""
Utils submodule for fitz compatibility.
This provides the utils submodule that pdf2docx expects.
"""

# Import utils from pymupdf if available
try:
    from pymupdf import utils as _pymupdf_utils
    # Make all pymupdf utils available
    for attr in dir(_pymupdf_utils):
        if not attr.startswith('_'):
            globals()[attr] = getattr(_pymupdf_utils, attr)
except ImportError:
    # If pymupdf utils is not available, create a minimal utils module
    pass

# Common utils functions that might be expected
def get_pixmap(*args, **kwargs):
    """Get pixmap from pymupdf."""
    import pymupdf
    return pymupdf.Pixmap(*args, **kwargs)

def get_text(*args, **kwargs):
    """Get text from pymupdf."""
    import pymupdf
    return pymupdf.get_text(*args, **kwargs)
