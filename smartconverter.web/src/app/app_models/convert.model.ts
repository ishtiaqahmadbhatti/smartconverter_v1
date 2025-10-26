export class ConvertModel {
  ID: number = 0;
  FullName: string = "";
  Email: string = "";
  Password: string = "";
}

export class PDFOperationResponse {
  success: boolean = false;
  message: string = "";
  output_filename: string = "";
  download_url: string = "";
}
