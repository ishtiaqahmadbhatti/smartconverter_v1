# Smart Converter

A futuristic Flutter application for file conversion with a modern, advanced UI design.

## Features

### 🎨 **Futuristic UI Design**
- Modern gradient-based color scheme
- Smooth animations and transitions
- Glassmorphic and futuristic card designs
- Responsive layout for all screen sizes

### 🚀 **Animated Splash Screen**
- Fully animated logo with rotation and scaling effects
- Floating background orbs with smooth animations
- Smooth transition to home page

### 🏠 **Home Page**
- **AppBar**: Custom gradient logo and notification icon
- **Bottom Navigation**: Home, Tools, History, Settings tabs
- **Drawer Menu**: User profile, navigation items, and app settings
- **Quick Stats**: Real-time conversion statistics
- **Tools Grid**: Interactive conversion tool cards
- **Recent Activity**: List of recent conversions

### 🛠️ **Conversion Tools**
- **PDF ⇄ Word**: Convert PDF documents to Word and vice versa
- **Image ⇄ PDF**: Convert images to PDF and extract images from PDF
- **Text ⇄ Word**: Convert text files to Word documents
- **Word ⇄ Text**: Convert Word documents to text files
- **HTML ⇄ PDF**: Convert HTML files to PDF documents

### 🔧 **Technical Features**
- **Service Layer**: Placeholder API integration ready for FastAPI backend
- **File Picker**: Support for multiple file types and formats
- **State Management**: Provider pattern implementation
- **Responsive Design**: Works on mobile, tablet, and desktop
- **Error Handling**: Comprehensive error management and user feedback

## Project Structure

```
lib/
├── constants/
│   ├── app_colors.dart      # Color scheme and gradients
│   ├── app_strings.dart     # App strings and labels
│   └── app_theme.dart       # Theme configuration
├── models/
│   └── conversion_tool.dart # Data models
├── services/
│   └── conversion_service.dart # API and business logic
├── utils/
│   └── responsive_helper.dart # Responsive design utilities
├── views/
│   ├── splash_screen.dart   # Animated splash screen
│   ├── home_page.dart       # Main home page
│   └── tool_detail_page.dart # Individual tool pages
├── widgets/
│   ├── futuristic_card.dart # Custom card components
│   ├── tool_card.dart       # Tool display cards
│   └── custom_drawer.dart   # Navigation drawer
└── main.dart               # App entry point
```

## Dependencies

- **flutter**: SDK
- **provider**: State management
- **go_router**: Navigation routing
- **flutter_animate**: Advanced animations
- **google_fonts**: Typography
- **file_picker**: File selection
- **dio**: HTTP client for API calls
- **shared_preferences**: Local storage

## Getting Started

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd smartconverter
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   flutter run
   ```

## Backend Integration

The app is designed to work with a Python FastAPI backend. The service layer includes placeholder methods for:

- File conversion APIs
- Status checking
- File download
- Error handling

To integrate with your FastAPI backend:

1. Update the `baseUrl` in `ConversionService`
2. Implement the actual API calls in the service methods
3. Handle authentication and file upload/download

## Design Philosophy

### 🎨 **Futuristic Aesthetic**
- Dark theme with electric blue and purple gradients
- Glowing effects and smooth animations
- Clean, modern typography using Inter font
- Glassmorphic elements for depth

### 📱 **Responsive Design**
- Mobile-first approach
- Adaptive layouts for different screen sizes
- Touch-friendly interactive elements
- Optimized for both portrait and landscape orientations

### ⚡ **Performance**
- Efficient animations using Flutter's animation framework
- Lazy loading and optimized rendering
- Minimal memory footprint
- Smooth 60fps animations

## Future Enhancements

- [ ] Real-time conversion progress tracking
- [ ] Cloud storage integration
- [ ] Batch file processing
- [ ] Advanced file format support
- [ ] User authentication and profiles
- [ ] Conversion history and favorites
- [ ] Push notifications
- [ ] Dark/Light theme toggle

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contact

For questions or support, please contact [your-email@example.com]

---

**Smart Converter** - Transform Your Files with AI ✨