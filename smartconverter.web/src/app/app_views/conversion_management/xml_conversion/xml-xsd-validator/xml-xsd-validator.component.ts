import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { FileConversionUiComponent } from '../../../../app_shared/file-conversion-ui/file-conversion-ui.component';
import { BaseXmlToolComponent } from '../base-xml-tool.component';

@Component({
  selector: 'app-xml-xsd-validator',
  imports: [CommonModule, FormsModule, FileConversionUiComponent],
  templateUrl: './xml-xsd-validator.component.html',
  styleUrl: './xml-xsd-validator.component.css',
  standalone: true
})
export class XmlXsdValidatorComponent extends BaseXmlToolComponent {
  toolId = 'xml-xsd-validator';
}
