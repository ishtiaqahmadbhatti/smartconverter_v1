import { ConversionTool } from '../app_models/conversion-tool.model';

export const JSON_CONVERSION_TOOLS: ConversionTool[] = [
    {
        id: 'ai-pdf-to-json',
        title: 'AI PDF to JSON',
        description: 'Extract structured JSON data from PDF documents using AI.',
        sourceIcon: 'fas fa-file-pdf',
        targetIcon: 'fas fa-file-code',
        route: 'ai-pdf-to-json'
    },
    {
        id: 'ai-png-to-json',
        title: 'AI PNG to JSON',
        description: 'Convert PNG images to structured JSON data using AI.',
        sourceIcon: 'fas fa-file-image',
        targetIcon: 'fas fa-file-code',
        route: 'ai-png-to-json'
    },
    {
        id: 'ai-jpg-to-json',
        title: 'AI JPG to JSON',
        description: 'Convert JPG images to structured JSON data using AI.',
        sourceIcon: 'fas fa-file-image',
        targetIcon: 'fas fa-file-code',
        route: 'ai-jpg-to-json'
    },
    {
        id: 'xml-to-json',
        title: 'XML to JSON',
        description: 'Convert XML data to JSON format.',
        sourceIcon: 'fas fa-code',
        targetIcon: 'fas fa-file-code',
        route: 'xml-to-json'
    },
    {
        id: 'json-formatter',
        title: 'Format JSON',
        description: 'Beautify and format your JSON data for better readability.',
        sourceIcon: 'fas fa-file-code',
        targetIcon: 'fas fa-align-left',
        route: 'json-formatter'
    },
    {
        id: 'json-validator',
        title: 'Validate JSON',
        description: 'Validate your JSON data against standards.',
        sourceIcon: 'fas fa-file-code',
        targetIcon: 'fas fa-check-double',
        route: 'json-validator'
    },
    {
        id: 'json-to-xml',
        title: 'JSON to XML',
        description: 'Convert JSON data to XML format.',
        sourceIcon: 'fas fa-file-code',
        targetIcon: 'fas fa-code',
        route: 'json-to-xml'
    },
    {
        id: 'json-to-csv',
        title: 'JSON to CSV',
        description: 'Convert JSON data to Comma Separated Values (CSV) format.',
        sourceIcon: 'fas fa-file-code',
        targetIcon: 'fas fa-file-csv',
        route: 'json-to-csv'
    },
    {
        id: 'json-to-excel',
        title: 'JSON to Excel',
        description: 'Convert JSON data to Excel spreadsheet.',
        sourceIcon: 'fas fa-file-code',
        targetIcon: 'fas fa-file-excel',
        route: 'json-to-excel'
    },
    {
        id: 'excel-to-json',
        title: 'Excel to JSON',
        description: 'Convert Excel spreadsheets to JSON format.',
        sourceIcon: 'fas fa-file-excel',
        targetIcon: 'fas fa-file-code',
        route: 'excel-to-json'
    },
    {
        id: 'csv-to-json',
        title: 'CSV to JSON',
        description: 'Convert CSV files to JSON format.',
        sourceIcon: 'fas fa-file-csv',
        targetIcon: 'fas fa-file-code',
        route: 'csv-to-json'
    },
    {
        id: 'json-to-yaml',
        title: 'JSON to YAML',
        description: 'Convert JSON data to YAML format.',
        sourceIcon: 'fas fa-file-code',
        targetIcon: 'fas fa-file-alt',
        route: 'json-to-yaml'
    },
    {
        id: 'json-objects-to-csv',
        title: 'JSON Objects to CSV',
        description: 'Convert a list of JSON objects to CSV.',
        sourceIcon: 'fas fa-cubes',
        targetIcon: 'fas fa-file-csv',
        route: 'json-objects-to-csv'
    },
    {
        id: 'json-objects-to-excel',
        title: 'JSON Objects to Excel',
        description: 'Convert a list of JSON objects to Excel.',
        sourceIcon: 'fas fa-cubes',
        targetIcon: 'fas fa-file-excel',
        route: 'json-objects-to-excel'
    },
    {
        id: 'yaml-to-json',
        title: 'YAML to JSON',
        description: 'Convert YAML data to JSON format.',
        sourceIcon: 'fas fa-file-alt',
        targetIcon: 'fas fa-file-code',
        route: 'yaml-to-json'
    }
];
