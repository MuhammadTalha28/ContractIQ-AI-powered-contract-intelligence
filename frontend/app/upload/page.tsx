'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import { useDropzone } from 'react-dropzone'
import axios from 'axios'

export default function UploadPage() {
  const router = useRouter()
  const [file, setFile] = useState<File | null>(null)
  const [isUploading, setIsUploading] = useState(false)
  const [uploadProgress, setUploadProgress] = useState(0)

  const onDrop = (acceptedFiles: File[]) => {
    if (acceptedFiles.length > 0) {
      setFile(acceptedFiles[0])
    }
  }

  const { getRootProps, getInputProps, isDragActive } = useDropzone({
    onDrop,
    accept: {
      'application/pdf': ['.pdf'],
    },
    maxFiles: 1,
  })

  const handleUpload = async () => {
    if (!file) return

    setIsUploading(true)
    setUploadProgress(0)

    try {
      // Convert file to base64
      const reader = new FileReader()
      reader.onload = async (e) => {
        try {
          const base64Content = (e.target?.result as string).split(',')[1] // Remove data:application/pdf;base64, prefix
          
          setUploadProgress(50)

          const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'https://YOUR_API_GATEWAY_URL/dev'
          const response = await axios.post(
            `${apiUrl}/upload`,
            {
              file_content: base64Content,
              filename: file.name,
            },
            {
              headers: {
                'Content-Type': 'application/json',
              },
            }
          )

          setUploadProgress(100)

          if (response.data.contractId) {
            router.push(`/dashboard?contract=${response.data.contractId}`)
          } else {
            alert('Upload successful! Processing will begin shortly.')
            router.push('/dashboard')
          }
        } catch (error: any) {
          console.error('Upload failed:', error)
          alert(`Upload failed: ${error.response?.data?.error || error.message}`)
          setIsUploading(false)
        }
      }
      reader.onerror = () => {
        alert('Failed to read file')
        setIsUploading(false)
      }
      reader.readAsDataURL(file)
    } catch (error) {
      console.error('Upload failed:', error)
      alert('Upload failed. Please try again.')
      setIsUploading(false)
    }
  }

  return (
    <div className="min-h-screen bg-gray-50 py-12 px-4">
      <div className="max-w-3xl mx-auto">
        <h1 className="text-3xl font-bold text-gray-900 mb-8">Upload Contract</h1>

        <div className="bg-white rounded-lg shadow-lg p-8">
          <div
            {...getRootProps()}
            className={`border-2 border-dashed rounded-lg p-12 text-center cursor-pointer transition ${
              isDragActive
                ? 'border-primary-500 bg-primary-50'
                : 'border-gray-300 hover:border-primary-400'
            }`}
          >
            <input {...getInputProps()} />
            {file ? (
              <div>
                <p className="text-lg text-gray-700 mb-2">Selected file:</p>
                <p className="text-primary-600 font-semibold">{file.name}</p>
                <p className="text-sm text-gray-500 mt-2">
                  {(file.size / 1024 / 1024).toFixed(2)} MB
                </p>
              </div>
            ) : (
              <div>
                <p className="text-lg text-gray-700 mb-2">
                  {isDragActive
                    ? 'Drop the file here'
                    : 'Drag & drop a PDF contract here, or click to select'}
                </p>
                <p className="text-sm text-gray-500">PDF files only</p>
              </div>
            )}
          </div>

          {file && (
            <div className="mt-6">
              <button
                onClick={handleUpload}
                disabled={isUploading}
                className="w-full bg-primary-600 text-white py-3 rounded-lg font-semibold hover:bg-primary-700 disabled:opacity-50 disabled:cursor-not-allowed transition"
              >
                {isUploading ? `Uploading... ${uploadProgress}%` : 'Upload & Analyze'}
              </button>
            </div>
          )}

          {isUploading && (
            <div className="mt-4">
              <div className="w-full bg-gray-200 rounded-full h-2">
                <div
                  className="bg-primary-600 h-2 rounded-full transition-all duration-300"
                  style={{ width: `${uploadProgress}%` }}
                />
              </div>
            </div>
          )}
        </div>

        <div className="mt-8 bg-blue-50 rounded-lg p-6">
          <h2 className="text-lg font-semibold text-gray-800 mb-2">
            What happens next?
          </h2>
          <ul className="list-disc list-inside text-gray-600 space-y-1">
            <li>Document is uploaded to S3</li>
            <li>Textract extracts text from PDF</li>
            <li>Bedrock AI analyzes clauses and risks</li>
            <li>SageMaker calculates risk score</li>
            <li>Results saved to DynamoDB and RDS</li>
            <li>You receive an email notification</li>
          </ul>
        </div>
      </div>
    </div>
  )
}

