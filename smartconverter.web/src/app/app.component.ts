import { Component } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { HeaderComponent } from './app_layouts/header/header.component';
import { FooterComponent } from './app_layouts/footer/footer.component';
import { ToastComponent } from './app_layouts/toast/toast';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrl: './app.component.css',
  standalone: true,
  imports: [RouterOutlet, HeaderComponent, FooterComponent, ToastComponent],
})
export class AppComponent {
  title = 'SmartConverter';
}