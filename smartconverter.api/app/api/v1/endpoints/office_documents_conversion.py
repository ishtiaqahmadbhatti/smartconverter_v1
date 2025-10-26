"""
Office Documents Conversion API Endpoints

This module provides API endpoints for various office document conversion operations.
"""

from fastapi import APIRouter, UploadFile, File, Form, HTTPException, Depends
from fastapi.responses import FileResponse
from typing import Optional
import os
import logging

from app.services.office_documents_conversion_service import OfficeDocumentsConversionService
from app.models.schemas import ConversionResponse
from app.core.exceptions import create_error_response

logger = logging.getLogger(__name__)

router = APIRouter()


@router.post("/pdf-to-csv", response_model=ConversionResponse)
async def convert_pdf_to_csv(file: UploadFile = File(...)):
    """Convert PDF to CSV."""
    try:
        if not file.filename.lower().endswith('.pdf'):
            raise HTTPException(status_code=400, detail="File must be a PDF")
        
        file_content = await file.read()
        csv_content = OfficeDocumentsConversionService.pdf_to_csv(file_content)
        
        return ConversionResponse(
            success=True,
            message="PDF converted to CSV successfully",
            converted_data=csv_content,
            download_url=None
        )
        
    except Exception as e:
        logger.error(f"Error converting PDF to CSV: {str(e)}")
        return create_error_response("Failed to convert PDF to CSV", str(e))


@router.post("/pdf-to-excel", response_model=ConversionResponse)
async def convert_pdf_to_excel(file: UploadFile = File(...)):
    """Convert PDF to Excel."""
    try:
        if not file.filename.lower().endswith('.pdf'):
            raise HTTPException(status_code=400, detail="File must be a PDF")
        
        file_content = await file.read()
        output_path = OfficeDocumentsConversionService.pdf_to_excel(file_content)
        
        # Create download URL
        filename = os.path.basename(output_path)
        download_url = f"/api/v1/officedocumentsconversiontools/download/{filename}"
        
        return ConversionResponse(
            success=True,
            message="PDF converted to Excel successfully",
            converted_data=None,
            download_url=download_url
        )
        
    except Exception as e:
        logger.error(f"Error converting PDF to Excel: {str(e)}")
        return create_error_response("Failed to convert PDF to Excel", str(e))


@router.post("/pdf-to-word", response_model=ConversionResponse)
async def convert_pdf_to_word(file: UploadFile = File(...)):
    """Convert PDF to Word document."""
    try:
        if not file.filename.lower().endswith('.pdf'):
            raise HTTPException(status_code=400, detail="File must be a PDF")
        
        file_content = await file.read()
        output_path = OfficeDocumentsConversionService.pdf_to_word(file_content)
        
        # Create download URL
        filename = os.path.basename(output_path)
        download_url = f"/api/v1/officedocumentsconversiontools/download/{filename}"
        
        return ConversionResponse(
            success=True,
            message="PDF converted to Word successfully",
            converted_data=None,
            download_url=download_url
        )
        
    except Exception as e:
        logger.error(f"Error converting PDF to Word: {str(e)}")
        return create_error_response("Failed to convert PDF to Word", str(e))


@router.post("/word-to-pdf", response_model=ConversionResponse)
async def convert_word_to_pdf(file: UploadFile = File(...)):
    """Convert Word document to PDF."""
    try:
        if not file.filename.lower().endswith(('.docx', '.doc')):
            raise HTTPException(status_code=400, detail="File must be a Word document")
        
        file_content = await file.read()
        output_path = OfficeDocumentsConversionService.word_to_pdf(file_content)
        
        # Create download URL
        filename = os.path.basename(output_path)
        download_url = f"/api/v1/officedocumentsconversiontools/download/{filename}"
        
        return ConversionResponse(
            success=True,
            message="Word document converted to PDF successfully",
            converted_data=None,
            download_url=download_url
        )
        
    except Exception as e:
        logger.error(f"Error converting Word to PDF: {str(e)}")
        return create_error_response("Failed to convert Word to PDF", str(e))


@router.post("/word-to-html", response_model=ConversionResponse)
async def convert_word_to_html(file: UploadFile = File(...)):
    """Convert Word document to HTML."""
    try:
        if not file.filename.lower().endswith(('.docx', '.doc')):
            raise HTTPException(status_code=400, detail="File must be a Word document")
        
        file_content = await file.read()
        html_content = OfficeDocumentsConversionService.word_to_html(file_content)
        
        return ConversionResponse(
            success=True,
            message="Word document converted to HTML successfully",
            converted_data=html_content,
            download_url=None
        )
        
    except Exception as e:
        logger.error(f"Error converting Word to HTML: {str(e)}")
        return create_error_response("Failed to convert Word to HTML", str(e))


@router.post("/word-to-text", response_model=ConversionResponse)
async def convert_word_to_text(file: UploadFile = File(...)):
    """Convert Word document to text."""
    try:
        if not file.filename.lower().endswith(('.docx', '.doc')):
            raise HTTPException(status_code=400, detail="File must be a Word document")
        
        file_content = await file.read()
        text_content = OfficeDocumentsConversionService.word_to_text(file_content)
        
        return ConversionResponse(
            success=True,
            message="Word document converted to text successfully",
            converted_data=text_content,
            download_url=None
        )
        
    except Exception as e:
        logger.error(f"Error converting Word to text: {str(e)}")
        return create_error_response("Failed to convert Word to text", str(e))


@router.post("/powerpoint-to-pdf", response_model=ConversionResponse)
async def convert_powerpoint_to_pdf(file: UploadFile = File(...)):
    """Convert PowerPoint presentation to PDF."""
    try:
        if not file.filename.lower().endswith(('.pptx', '.ppt')):
            raise HTTPException(status_code=400, detail="File must be a PowerPoint presentation")
        
        file_content = await file.read()
        output_path = OfficeDocumentsConversionService.powerpoint_to_pdf(file_content)
        
        # Create download URL
        filename = os.path.basename(output_path)
        download_url = f"/api/v1/officedocumentsconversiontools/download/{filename}"
        
        return ConversionResponse(
            success=True,
            message="PowerPoint presentation converted to PDF successfully",
            converted_data=None,
            download_url=download_url
        )
        
    except Exception as e:
        logger.error(f"Error converting PowerPoint to PDF: {str(e)}")
        return create_error_response("Failed to convert PowerPoint to PDF", str(e))


@router.post("/powerpoint-to-html", response_model=ConversionResponse)
async def convert_powerpoint_to_html(file: UploadFile = File(...)):
    """Convert PowerPoint presentation to HTML."""
    try:
        if not file.filename.lower().endswith(('.pptx', '.ppt')):
            raise HTTPException(status_code=400, detail="File must be a PowerPoint presentation")
        
        file_content = await file.read()
        html_content = OfficeDocumentsConversionService.powerpoint_to_html(file_content)
        
        return ConversionResponse(
            success=True,
            message="PowerPoint presentation converted to HTML successfully",
            converted_data=html_content,
            download_url=None
        )
        
    except Exception as e:
        logger.error(f"Error converting PowerPoint to HTML: {str(e)}")
        return create_error_response("Failed to convert PowerPoint to HTML", str(e))


@router.post("/powerpoint-to-text", response_model=ConversionResponse)
async def convert_powerpoint_to_text(file: UploadFile = File(...)):
    """Convert PowerPoint presentation to text."""
    try:
        if not file.filename.lower().endswith(('.pptx', '.ppt')):
            raise HTTPException(status_code=400, detail="File must be a PowerPoint presentation")
        
        file_content = await file.read()
        text_content = OfficeDocumentsConversionService.powerpoint_to_text(file_content)
        
        return ConversionResponse(
            success=True,
            message="PowerPoint presentation converted to text successfully",
            converted_data=text_content,
            download_url=None
        )
        
    except Exception as e:
        logger.error(f"Error converting PowerPoint to text: {str(e)}")
        return create_error_response("Failed to convert PowerPoint to text", str(e))


@router.post("/excel-to-pdf", response_model=ConversionResponse)
async def convert_excel_to_pdf(file: UploadFile = File(...)):
    """Convert Excel file to PDF."""
    try:
        if not file.filename.lower().endswith(('.xlsx', '.xls')):
            raise HTTPException(status_code=400, detail="File must be an Excel file")
        
        file_content = await file.read()
        output_path = OfficeDocumentsConversionService.excel_to_pdf(file_content)
        
        # Create download URL
        filename = os.path.basename(output_path)
        download_url = f"/api/v1/officedocumentsconversiontools/download/{filename}"
        
        return ConversionResponse(
            success=True,
            message="Excel file converted to PDF successfully",
            converted_data=None,
            download_url=download_url
        )
        
    except Exception as e:
        logger.error(f"Error converting Excel to PDF: {str(e)}")
        return create_error_response("Failed to convert Excel to PDF", str(e))


@router.post("/excel-to-xps", response_model=ConversionResponse)
async def convert_excel_to_xps(file: UploadFile = File(...)):
    """Convert Excel file to XPS."""
    try:
        if not file.filename.lower().endswith(('.xlsx', '.xls')):
            raise HTTPException(status_code=400, detail="File must be an Excel file")
        
        file_content = await file.read()
        output_path = OfficeDocumentsConversionService.excel_to_xps(file_content)
        
        # Create download URL
        filename = os.path.basename(output_path)
        download_url = f"/api/v1/officedocumentsconversiontools/download/{filename}"
        
        return ConversionResponse(
            success=True,
            message="Excel file converted to XPS successfully",
            converted_data=None,
            download_url=download_url
        )
        
    except Exception as e:
        logger.error(f"Error converting Excel to XPS: {str(e)}")
        return create_error_response("Failed to convert Excel to XPS", str(e))


@router.post("/excel-to-html", response_model=ConversionResponse)
async def convert_excel_to_html(file: UploadFile = File(...)):
    """Convert Excel file to HTML."""
    try:
        if not file.filename.lower().endswith(('.xlsx', '.xls')):
            raise HTTPException(status_code=400, detail="File must be an Excel file")
        
        file_content = await file.read()
        html_content = OfficeDocumentsConversionService.excel_to_html(file_content)
        
        return ConversionResponse(
            success=True,
            message="Excel file converted to HTML successfully",
            converted_data=html_content,
            download_url=None
        )
        
    except Exception as e:
        logger.error(f"Error converting Excel to HTML: {str(e)}")
        return create_error_response("Failed to convert Excel to HTML", str(e))


@router.post("/excel-to-csv", response_model=ConversionResponse)
async def convert_excel_to_csv(file: UploadFile = File(...)):
    """Convert Excel file to CSV."""
    try:
        if not file.filename.lower().endswith(('.xlsx', '.xls')):
            raise HTTPException(status_code=400, detail="File must be an Excel file")
        
        file_content = await file.read()
        csv_content = OfficeDocumentsConversionService.excel_to_csv(file_content)
        
        return ConversionResponse(
            success=True,
            message="Excel file converted to CSV successfully",
            converted_data=csv_content,
            download_url=None
        )
        
    except Exception as e:
        logger.error(f"Error converting Excel to CSV: {str(e)}")
        return create_error_response("Failed to convert Excel to CSV", str(e))


@router.post("/excel-to-ods", response_model=ConversionResponse)
async def convert_excel_to_ods(file: UploadFile = File(...)):
    """Convert Excel file to OpenOffice Calc ODS."""
    try:
        if not file.filename.lower().endswith(('.xlsx', '.xls')):
            raise HTTPException(status_code=400, detail="File must be an Excel file")
        
        file_content = await file.read()
        output_path = OfficeDocumentsConversionService.excel_to_ods(file_content)
        
        # Create download URL
        filename = os.path.basename(output_path)
        download_url = f"/api/v1/officedocumentsconversiontools/download/{filename}"
        
        return ConversionResponse(
            success=True,
            message="Excel file converted to ODS successfully",
            converted_data=None,
            download_url=download_url
        )
        
    except Exception as e:
        logger.error(f"Error converting Excel to ODS: {str(e)}")
        return create_error_response("Failed to convert Excel to ODS", str(e))


@router.post("/ods-to-csv", response_model=ConversionResponse)
async def convert_ods_to_csv(file: UploadFile = File(...)):
    """Convert OpenOffice Calc ODS file to CSV."""
    try:
        if not file.filename.lower().endswith('.ods'):
            raise HTTPException(status_code=400, detail="File must be an ODS file")
        
        file_content = await file.read()
        csv_content = OfficeDocumentsConversionService.ods_to_csv(file_content)
        
        return ConversionResponse(
            success=True,
            message="ODS file converted to CSV successfully",
            converted_data=csv_content,
            download_url=None
        )
        
    except Exception as e:
        logger.error(f"Error converting ODS to CSV: {str(e)}")
        return create_error_response("Failed to convert ODS to CSV", str(e))


@router.post("/ods-to-pdf", response_model=ConversionResponse)
async def convert_ods_to_pdf(file: UploadFile = File(...)):
    """Convert OpenOffice Calc ODS file to PDF."""
    try:
        if not file.filename.lower().endswith('.ods'):
            raise HTTPException(status_code=400, detail="File must be an ODS file")
        
        file_content = await file.read()
        output_path = OfficeDocumentsConversionService.ods_to_pdf(file_content)
        
        # Create download URL
        filename = os.path.basename(output_path)
        download_url = f"/api/v1/officedocumentsconversiontools/download/{filename}"
        
        return ConversionResponse(
            success=True,
            message="ODS file converted to PDF successfully",
            converted_data=None,
            download_url=download_url
        )
        
    except Exception as e:
        logger.error(f"Error converting ODS to PDF: {str(e)}")
        return create_error_response("Failed to convert ODS to PDF", str(e))


@router.post("/ods-to-excel", response_model=ConversionResponse)
async def convert_ods_to_excel(file: UploadFile = File(...)):
    """Convert OpenOffice Calc ODS file to Excel."""
    try:
        if not file.filename.lower().endswith('.ods'):
            raise HTTPException(status_code=400, detail="File must be an ODS file")
        
        file_content = await file.read()
        output_path = OfficeDocumentsConversionService.ods_to_excel(file_content)
        
        # Create download URL
        filename = os.path.basename(output_path)
        download_url = f"/api/v1/officedocumentsconversiontools/download/{filename}"
        
        return ConversionResponse(
            success=True,
            message="ODS file converted to Excel successfully",
            converted_data=None,
            download_url=download_url
        )
        
    except Exception as e:
        logger.error(f"Error converting ODS to Excel: {str(e)}")
        return create_error_response("Failed to convert ODS to Excel", str(e))


@router.post("/csv-to-excel", response_model=ConversionResponse)
async def convert_csv_to_excel(csv_content: str = Form(...)):
    """Convert CSV to Excel file."""
    try:
        output_path = OfficeDocumentsConversionService.csv_to_excel(csv_content)
        
        # Create download URL
        filename = os.path.basename(output_path)
        download_url = f"/api/v1/officedocumentsconversiontools/download/{filename}"
        
        return ConversionResponse(
            success=True,
            message="CSV converted to Excel successfully",
            converted_data=None,
            download_url=download_url
        )
        
    except Exception as e:
        logger.error(f"Error converting CSV to Excel: {str(e)}")
        return create_error_response("Failed to convert CSV to Excel", str(e))


@router.post("/excel-to-xml", response_model=ConversionResponse)
async def convert_excel_to_xml(file: UploadFile = File(...), root_name: str = Form("data"), record_name: str = Form("record")):
    """Convert Excel file to XML."""
    try:
        if not file.filename.lower().endswith(('.xlsx', '.xls')):
            raise HTTPException(status_code=400, detail="File must be an Excel file")
        
        file_content = await file.read()
        xml_content = OfficeDocumentsConversionService.excel_to_xml(file_content, root_name, record_name)
        
        return ConversionResponse(
            success=True,
            message="Excel file converted to XML successfully",
            converted_data=xml_content,
            download_url=None
        )
        
    except Exception as e:
        logger.error(f"Error converting Excel to XML: {str(e)}")
        return create_error_response("Failed to convert Excel to XML", str(e))


@router.post("/xml-to-csv", response_model=ConversionResponse)
async def convert_xml_to_csv(xml_content: str = Form(...)):
    """Convert XML to CSV."""
    try:
        csv_content = OfficeDocumentsConversionService.xml_to_csv(xml_content)
        
        return ConversionResponse(
            success=True,
            message="XML converted to CSV successfully",
            converted_data=csv_content,
            download_url=None
        )
        
    except Exception as e:
        logger.error(f"Error converting XML to CSV: {str(e)}")
        return create_error_response("Failed to convert XML to CSV", str(e))


@router.post("/xml-to-excel", response_model=ConversionResponse)
async def convert_xml_to_excel(xml_content: str = Form(...)):
    """Convert XML to Excel file."""
    try:
        output_path = OfficeDocumentsConversionService.xml_to_excel(xml_content)
        
        # Create download URL
        filename = os.path.basename(output_path)
        download_url = f"/api/v1/officedocumentsconversiontools/download/{filename}"
        
        return ConversionResponse(
            success=True,
            message="XML converted to Excel successfully",
            converted_data=None,
            download_url=download_url
        )
        
    except Exception as e:
        logger.error(f"Error converting XML to Excel: {str(e)}")
        return create_error_response("Failed to convert XML to Excel", str(e))


@router.post("/excel-xml-to-xlsx", response_model=ConversionResponse)
async def convert_excel_xml_to_xlsx(file: UploadFile = File(...)):
    """Convert Excel XML to Excel XLSX file."""
    try:
        if not file.filename.lower().endswith('.xml'):
            raise HTTPException(status_code=400, detail="File must be an XML file")
        
        file_content = await file.read()
        output_path = OfficeDocumentsConversionService.excel_xml_to_xlsx(file_content)
        
        # Create download URL
        filename = os.path.basename(output_path)
        download_url = f"/api/v1/officedocumentsconversiontools/download/{filename}"
        
        return ConversionResponse(
            success=True,
            message="Excel XML converted to XLSX successfully",
            converted_data=None,
            download_url=download_url
        )
        
    except Exception as e:
        logger.error(f"Error converting Excel XML to XLSX: {str(e)}")
        return create_error_response("Failed to convert Excel XML to XLSX", str(e))


@router.post("/json-to-excel", response_model=ConversionResponse)
async def convert_json_to_excel(json_data: dict):
    """Convert JSON to Excel file."""
    try:
        output_path = OfficeDocumentsConversionService.json_to_excel(json_data)
        
        # Create download URL
        filename = os.path.basename(output_path)
        download_url = f"/api/v1/officedocumentsconversiontools/download/{filename}"
        
        return ConversionResponse(
            success=True,
            message="JSON converted to Excel successfully",
            converted_data=None,
            download_url=download_url
        )
        
    except Exception as e:
        logger.error(f"Error converting JSON to Excel: {str(e)}")
        return create_error_response("Failed to convert JSON to Excel", str(e))


@router.post("/excel-to-json", response_model=ConversionResponse)
async def convert_excel_to_json(file: UploadFile = File(...)):
    """Convert Excel file to JSON."""
    try:
        if not file.filename.lower().endswith(('.xlsx', '.xls')):
            raise HTTPException(status_code=400, detail="File must be an Excel file")
        
        file_content = await file.read()
        json_content = OfficeDocumentsConversionService.excel_to_json(file_content)
        
        return ConversionResponse(
            success=True,
            message="Excel file converted to JSON successfully",
            converted_data=json_content,
            download_url=None
        )
        
    except Exception as e:
        logger.error(f"Error converting Excel to JSON: {str(e)}")
        return create_error_response("Failed to convert Excel to JSON", str(e))


@router.post("/json-objects-to-excel", response_model=ConversionResponse)
async def convert_json_objects_to_excel(json_objects: list):
    """Convert JSON objects to Excel file."""
    try:
        output_path = OfficeDocumentsConversionService.json_objects_to_excel(json_objects)
        
        # Create download URL
        filename = os.path.basename(output_path)
        download_url = f"/api/v1/officedocumentsconversiontools/download/{filename}"
        
        return ConversionResponse(
            success=True,
            message="JSON objects converted to Excel successfully",
            converted_data=None,
            download_url=download_url
        )
        
    except Exception as e:
        logger.error(f"Error converting JSON objects to Excel: {str(e)}")
        return create_error_response("Failed to convert JSON objects to Excel", str(e))


@router.post("/bson-to-excel", response_model=ConversionResponse)
async def convert_bson_to_excel(file: UploadFile = File(...)):
    """Convert BSON to Excel file."""
    try:
        if not file.filename.lower().endswith('.bson'):
            raise HTTPException(status_code=400, detail="File must be a BSON file")
        
        file_content = await file.read()
        output_path = OfficeDocumentsConversionService.bson_to_excel(file_content)
        
        # Create download URL
        filename = os.path.basename(output_path)
        download_url = f"/api/v1/officedocumentsconversiontools/download/{filename}"
        
        return ConversionResponse(
            success=True,
            message="BSON converted to Excel successfully",
            converted_data=None,
            download_url=download_url
        )
        
    except Exception as e:
        logger.error(f"Error converting BSON to Excel: {str(e)}")
        return create_error_response("Failed to convert BSON to Excel", str(e))


@router.post("/srt-to-excel", response_model=ConversionResponse)
async def convert_srt_to_excel(srt_content: str = Form(...)):
    """Convert SRT subtitle file to Excel."""
    try:
        output_path = OfficeDocumentsConversionService.srt_to_excel(srt_content)
        
        # Create download URL
        filename = os.path.basename(output_path)
        download_url = f"/api/v1/officedocumentsconversiontools/download/{filename}"
        
        return ConversionResponse(
            success=True,
            message="SRT converted to Excel successfully",
            converted_data=None,
            download_url=download_url
        )
        
    except Exception as e:
        logger.error(f"Error converting SRT to Excel: {str(e)}")
        return create_error_response("Failed to convert SRT to Excel", str(e))


@router.post("/srt-to-xlsx", response_model=ConversionResponse)
async def convert_srt_to_xlsx(srt_content: str = Form(...)):
    """Convert SRT subtitle file to XLSX."""
    try:
        output_path = OfficeDocumentsConversionService.srt_to_xlsx(srt_content)
        
        # Create download URL
        filename = os.path.basename(output_path)
        download_url = f"/api/v1/officedocumentsconversiontools/download/{filename}"
        
        return ConversionResponse(
            success=True,
            message="SRT converted to XLSX successfully",
            converted_data=None,
            download_url=download_url
        )
        
    except Exception as e:
        logger.error(f"Error converting SRT to XLSX: {str(e)}")
        return create_error_response("Failed to convert SRT to XLSX", str(e))


@router.post("/srt-to-xls", response_model=ConversionResponse)
async def convert_srt_to_xls(srt_content: str = Form(...)):
    """Convert SRT subtitle file to XLS."""
    try:
        output_path = OfficeDocumentsConversionService.srt_to_xls(srt_content)
        
        # Create download URL
        filename = os.path.basename(output_path)
        download_url = f"/api/v1/officedocumentsconversiontools/download/{filename}"
        
        return ConversionResponse(
            success=True,
            message="SRT converted to XLS successfully",
            converted_data=None,
            download_url=download_url
        )
        
    except Exception as e:
        logger.error(f"Error converting SRT to XLS: {str(e)}")
        return create_error_response("Failed to convert SRT to XLS", str(e))


@router.post("/excel-to-srt", response_model=ConversionResponse)
async def convert_excel_to_srt(file: UploadFile = File(...)):
    """Convert Excel file to SRT subtitle file."""
    try:
        if not file.filename.lower().endswith(('.xlsx', '.xls')):
            raise HTTPException(status_code=400, detail="File must be an Excel file")
        
        file_content = await file.read()
        srt_content = OfficeDocumentsConversionService.excel_to_srt(file_content)
        
        return ConversionResponse(
            success=True,
            message="Excel file converted to SRT successfully",
            converted_data=srt_content,
            download_url=None
        )
        
    except Exception as e:
        logger.error(f"Error converting Excel to SRT: {str(e)}")
        return create_error_response("Failed to convert Excel to SRT", str(e))


@router.post("/xlsx-to-srt", response_model=ConversionResponse)
async def convert_xlsx_to_srt(file: UploadFile = File(...)):
    """Convert XLSX file to SRT subtitle file."""
    try:
        if not file.filename.lower().endswith('.xlsx'):
            raise HTTPException(status_code=400, detail="File must be an XLSX file")
        
        file_content = await file.read()
        srt_content = OfficeDocumentsConversionService.xlsx_to_srt(file_content)
        
        return ConversionResponse(
            success=True,
            message="XLSX file converted to SRT successfully",
            converted_data=srt_content,
            download_url=None
        )
        
    except Exception as e:
        logger.error(f"Error converting XLSX to SRT: {str(e)}")
        return create_error_response("Failed to convert XLSX to SRT", str(e))


@router.post("/xls-to-srt", response_model=ConversionResponse)
async def convert_xls_to_srt(file: UploadFile = File(...)):
    """Convert XLS file to SRT subtitle file."""
    try:
        if not file.filename.lower().endswith('.xls'):
            raise HTTPException(status_code=400, detail="File must be an XLS file")
        
        file_content = await file.read()
        srt_content = OfficeDocumentsConversionService.xls_to_srt(file_content)
        
        return ConversionResponse(
            success=True,
            message="XLS file converted to SRT successfully",
            converted_data=srt_content,
            download_url=None
        )
        
    except Exception as e:
        logger.error(f"Error converting XLS to SRT: {str(e)}")
        return create_error_response("Failed to convert XLS to SRT", str(e))


@router.get("/download/{filename}")
async def download_file(filename: str):
    """Download converted file."""
    try:
        file_path = os.path.join("outputs", filename)
        
        if not os.path.exists(file_path):
            raise HTTPException(status_code=404, detail="File not found")
        
        return FileResponse(
            path=file_path,
            filename=filename,
            media_type='application/octet-stream'
        )
        
    except Exception as e:
        logger.error(f"Error downloading file: {str(e)}")
        raise HTTPException(status_code=500, detail="Failed to download file")
