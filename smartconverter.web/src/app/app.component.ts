import { Component } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { HeaderComponent } from './app_layouts/header/header.component';
import { SidebarComponent } from './app_layouts/sidebar/sidebar.component';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrl: './app.component.css',
  standalone: true,
  imports: [HeaderComponent, SidebarComponent, RouterOutlet],
})
export class AppComponent {
  title = 'SmartConvert_AngularWebApp';
}