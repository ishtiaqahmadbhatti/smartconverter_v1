"""
Compatibility package for fitz (PyMuPDF) imports.
This package provides a compatibility layer for packages that expect 'fitz' to be available.
"""

# Import everything from pymupdf and make it available as fitz
import pymupdf as _pymupdf

# Make all pymupdf attributes available at the module level
for attr in dir(_pymupdf):
    if not attr.startswith('_'):
        globals()[attr] = getattr(_pymupdf, attr)

# Ensure Matrix is available
Matrix = _pymupdf.Matrix

# Fix Rect object compatibility issues
if hasattr(_pymupdf, 'Rect'):
    class Rect(_pymupdf.Rect):
        """Enhanced Rect class with compatibility methods."""
        def get_area(self):
            """Get area of the rectangle."""
            return self.width * self.height
        
        def get_width(self):
            """Get width of the rectangle."""
            return self.width
        
        def get_height(self):
            """Get height of the rectangle."""
            return self.height
        
        def get_x0(self):
            """Get x0 coordinate."""
            return self.x0
        
        def get_y0(self):
            """Get y0 coordinate."""
            return self.y0
        
        def get_x1(self):
            """Get x1 coordinate."""
            return self.x1
        
        def get_y1(self):
            """Get y1 coordinate."""
            return self.y1
    
    # Replace the original Rect with our enhanced version
    Rect = Rect

# Create utils submodule
class utils:
    """Utils submodule for compatibility."""
    pass

# Make utils available
__all__ = ['Matrix', 'Rect', 'utils']
