'use client'

import Link from 'next/link'
import { useRouter } from 'next/navigation'
import { useState } from 'react'

export default function Home() {
  const router = useRouter()
  const [isLoading, setIsLoading] = useState(false)

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100">
      <div className="container mx-auto px-4 py-16">
        <div className="text-center mb-12">
          <h1 className="text-5xl font-bold text-gray-900 mb-4">
            Legal AI Contract Analyzer
          </h1>
          <p className="text-xl text-gray-600 mb-8">
            Enterprise-grade contract analysis powered by AWS AI/ML services
          </p>
        </div>

        <div className="max-w-4xl mx-auto grid md:grid-cols-2 gap-8 mb-12">
          <div className="bg-white rounded-lg shadow-lg p-6">
            <h2 className="text-2xl font-semibold mb-4 text-gray-800">
              Upload & Analyze
            </h2>
            <p className="text-gray-600 mb-4">
              Upload contracts, NDAs, and agreements. Our AI automatically extracts clauses,
              identifies risks, and provides comprehensive summaries.
            </p>
            <Link
              href="/upload"
              className="inline-block bg-primary-600 text-white px-6 py-3 rounded-lg hover:bg-primary-700 transition"
            >
              Upload Contract
            </Link>
          </div>

          <div className="bg-white rounded-lg shadow-lg p-6">
            <h2 className="text-2xl font-semibold mb-4 text-gray-800">
              View Dashboard
            </h2>
            <p className="text-gray-600 mb-4">
              Access your contract reviews, risk scores, and analysis history
              in one centralized dashboard.
            </p>
            <Link
              href="/dashboard"
              className="inline-block bg-primary-600 text-white px-6 py-3 rounded-lg hover:bg-primary-700 transition"
            >
              View Dashboard
            </Link>
          </div>
        </div>

        <div className="max-w-4xl mx-auto bg-white rounded-lg shadow-lg p-8">
          <h2 className="text-2xl font-semibold mb-6 text-gray-800">
            AWS Services Powering This Platform
          </h2>
          <div className="grid md:grid-cols-3 gap-4 text-sm">
            <div className="p-4 bg-blue-50 rounded">
              <strong>Lambda</strong> - Serverless processing
            </div>
            <div className="p-4 bg-blue-50 rounded">
              <strong>API Gateway</strong> - REST APIs
            </div>
            <div className="p-4 bg-blue-50 rounded">
              <strong>S3</strong> - Document storage
            </div>
            <div className="p-4 bg-blue-50 rounded">
              <strong>Textract</strong> - OCR extraction
            </div>
            <div className="p-4 bg-blue-50 rounded">
              <strong>Bedrock</strong> - LLM analysis
            </div>
            <div className="p-4 bg-blue-50 rounded">
              <strong>SageMaker</strong> - ML risk scoring
            </div>
            <div className="p-4 bg-blue-50 rounded">
              <strong>DynamoDB</strong> - Metadata storage
            </div>
            <div className="p-4 bg-blue-50 rounded">
              <strong>RDS</strong> - User database
            </div>
            <div className="p-4 bg-blue-50 rounded">
              <strong>SNS</strong> - Notifications
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}

